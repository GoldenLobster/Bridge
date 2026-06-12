import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../security/certificate_manager.dart';

final certificateManagerProvider = Provider<CertificateManager>((ref) {
  throw UnimplementedError(
    'CertificateManager must be overridden in main() after construction',
  );
});
