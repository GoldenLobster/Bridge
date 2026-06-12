import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:asn1lib/asn1lib.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

import '../database/database.dart';

/// Generates a self-signed X.509 certificate and RSA private key on first run,
/// stores them as PEMs in the Drift settings table, persists PEM files to disk,
/// and provides a local SecurityContext configured from those files.
class CertificateManager {
  final BridgeDatabase _db;
  SecurityContext? _localContext;
  String? _localCertPem;
  final Map<String, _TrustedEntry> _trusted = {};
  int _nextTrustedIndex = 0;

  CertificateManager(this._db);

  SecurityContext get localContext {
    if (_localContext == null) {
      throw StateError('CertificateManager not initialized');
    }
    return _localContext!;
  }

  String get localCertPem {
    if (_localCertPem == null) {
      throw StateError('CertificateManager not initialized');
    }
    return _localCertPem!;
  }

  Future<void> init() async {
    var certPem = await _getSetting('tlsCert');
    var keyPem = await _getSetting('tlsKey');

    if (certPem == null || keyPem == null) {
      final result = _generateCert();
      certPem = result.certPem;
      keyPem = result.keyPem;
      await _setSetting('tlsCert', certPem);
      await _setSetting('tlsKey', keyPem);
    }

    _localCertPem = certPem;

    final dir = await _certDir();
    final certFile = File(p.join(dir.path, 'bridge_cert.pem'));
    final keyFile = File(p.join(dir.path, 'bridge_key.pem'));
    await certFile.writeAsString(certPem);
    await keyFile.writeAsString(keyPem);

    _localContext = SecurityContext()
      ..useCertificateChain(certFile.path)
      ..usePrivateKey(keyFile.path);

    await _reloadTrusted();
  }

  Future<void> addTrustedCertificate(String deviceId, String certPem) async {
    final der = _pemToDer(certPem);
    final fingerprint = _computeFingerprint(der);
    _trusted[deviceId] = _TrustedEntry(certPem, fingerprint);
    await _setSetting('trusted_cert_$deviceId', certPem);

    final dir = await _certDir();
    final index = _nextTrustedIndex++;
    final file = File(p.join(dir.path, 'bridge_trusted_$index.pem'));
    await file.writeAsString(certPem);
    _localContext?.setTrustedCertificates(file.path);
  }

  String? getStoredFingerprint(String deviceId) {
    return _trusted[deviceId]?.fingerprint;
  }

  Future<void> _reloadTrusted() async {
    try {
      final rows = await _db.select(_db.settings).get();
      for (final row in rows) {
        if (row.key.startsWith('trusted_cert_')) {
          final deviceId = row.key.substring('trusted_cert_'.length);
          try {
            final der = _pemToDer(row.value);
            _trusted[deviceId] =
                _TrustedEntry(row.value, _computeFingerprint(der));
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  Future<String?> _getSetting(String key) async {
    final rows = await (_db.select(_db.settings)
          ..where((s) => s.key.equals(key)))
        .get();
    return rows.isEmpty ? null : rows.first.value;
  }

  Future<void> _setSetting(String key, String value) async {
    await _db.into(_db.settings).insert(
          SettingsCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<Directory> _certDir() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'certificates'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // ----- helpers -----------------------------------------------------------

  static Uint8List _pemToDer(String pem) {
    final b64 = pem
        .split('\n')
        .map((l) => l.trim())
        .where((l) => !l.startsWith('-----'))
        .join();
    return base64.decode(b64);
  }

  static String _encodePem(String label, Uint8List der) {
    final b64 = base64.encode(der);
    final buf = StringBuffer()..writeln('-----BEGIN $label-----');
    for (var i = 0; i < b64.length; i += 64) {
      buf.writeln(b64.substring(i, (i + 64).clamp(0, b64.length)));
    }
    buf.write('-----END $label-----');
    return buf.toString();
  }

  static String _computeFingerprint(Uint8List der) {
    final digest = SHA256Digest();
    final hash = digest.process(der);
    return base64.encode(hash);
  }

  // ----- RSA key pair + self-signed cert generation ------------------------

  static ({String certPem, String keyPem}) _generateCert() {
    final random = _createSecureRandom();
    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        random,
      ));
    final pair = keyGen.generateKeyPair();
    final priv = pair.privateKey as RSAPrivateKey;
    final pub = pair.publicKey as RSAPublicKey;

    final keyPem = _encodePem('RSA PRIVATE KEY', _encodeRsaPrivateKey(priv));

    final serial = BigInt.from(DateTime.now().millisecondsSinceEpoch);
    final notBefore = DateTime.now().subtract(const Duration(days: 1));
    final notAfter = DateTime.now().add(const Duration(days: 3650));

    final tbsDer = _buildTbsCertificate(serial, pub, notBefore, notAfter);
    final certDer = _signCertificate(tbsDer, priv, random);
    final certPem = _encodePem('CERTIFICATE', certDer);

    return (certPem: certPem, keyPem: keyPem);
  }

  static FortunaRandom _createSecureRandom() {
    final r = math.Random.secure();
    final seed = Uint8List.fromList(
      List.generate(32, (_) => r.nextInt(256)),
    );
    final f = FortunaRandom();
    f.seed(KeyParameter(seed));
    return f;
  }

  /// PKCS#1 RSAPrivateKey ::= SEQUENCE { version, modulus, publicExponent,
  /// privateExponent, prime1, prime2, exponent1, exponent2, coefficient }
  static Uint8List _encodeRsaPrivateKey(RSAPrivateKey key) {
    final seq = ASN1Sequence()
      ..add(ASN1Integer(BigInt.zero))
      ..add(ASN1Integer(key.modulus!))
      ..add(ASN1Integer(key.publicExponent!))
      ..add(ASN1Integer(key.privateExponent!))
      ..add(ASN1Integer(key.p!))
      ..add(ASN1Integer(key.q!))
      ..add(ASN1Integer(key.privateExponent! % (key.p! - BigInt.one)))
      ..add(ASN1Integer(key.privateExponent! % (key.q! - BigInt.one)))
      ..add(ASN1Integer(key.q!.modInverse(key.p!)));
    return seq.encodedBytes;
  }

  /// TBSCertificate for a self-signed X.509v3 cert.
  static Uint8List _buildTbsCertificate(
    BigInt serial,
    RSAPublicKey pub,
    DateTime notBefore,
    DateTime notAfter,
  ) {
    final tbs = ASN1Sequence();

    // version [0] EXPLICIT INTEGER 2  (v3)
    final versionWrap = ASN1Sequence(tag: 0xA0);
    versionWrap.add(ASN1Integer(BigInt.from(2)));
    tbs.add(versionWrap);

    tbs.add(ASN1Integer(serial));

    // signature algorithm — sha256WithRSAEncryption
    tbs.add(_algoId('1.2.840.113549.1.1.11'));

    // issuer
    tbs.add(_name('Bridge Device'));

    // validity
    final validity = ASN1Sequence()
      ..add(ASN1UtcTime(notBefore))
      ..add(ASN1UtcTime(notAfter));
    tbs.add(validity);

    // subject (self-signed)
    tbs.add(_name('Bridge Device'));

    // subjectPublicKeyInfo
    tbs.add(_pubKeyInfo(pub));

    return tbs.encodedBytes;
  }

  static ASN1Sequence _algoId(String oid) {
    final seq = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromComponentString(oid))
      ..add(ASN1Null());
    return seq;
  }

  static ASN1Sequence _name(String cn) {
    final rdn = ASN1Set()
      ..add(ASN1Sequence()
        ..add(ASN1ObjectIdentifier.fromComponentString('2.5.4.3'))
        ..add(ASN1UTF8String(cn)));
    return ASN1Sequence()..add(rdn);
  }

  static ASN1Sequence _pubKeyInfo(RSAPublicKey pub) {
    const rsaOid = '1.2.840.113549.1.1.1';
    final algoId = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromComponentString(rsaOid))
      ..add(ASN1Null());

    final rsaPub = ASN1Sequence()
      ..add(ASN1Integer(pub.modulus!))
      ..add(ASN1Integer(pub.publicExponent!));

    final bitStringPayload = Uint8List.fromList([0x00, ...rsaPub.encodedBytes]);

    final info = ASN1Sequence()
      ..add(algoId)
      ..add(ASN1Object.preEncoded(BIT_STRING_TYPE, bitStringPayload));
    return info;
  }

  /// Sign TBSCertificate and wrap in Certificate SEQUENCE.
  static Uint8List _signCertificate(
    Uint8List tbsDer,
    RSAPrivateKey priv,
    FortunaRandom random,
  ) {
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(priv));
    final sig = signer.generateSignature(tbsDer);

    final sigPayload = Uint8List.fromList([0x00, ...sig.bytes]);

    final cert = ASN1Sequence()
      ..add(ASN1Object.fromBytes(tbsDer))
      ..add(_algoId('1.2.840.113549.1.1.11'))
      ..add(ASN1Object.preEncoded(BIT_STRING_TYPE, sigPayload));

    return cert.encodedBytes;
  }
}

class _TrustedEntry {
  final String certPem;
  final String fingerprint;
  _TrustedEntry(this.certPem, this.fingerprint);
}
