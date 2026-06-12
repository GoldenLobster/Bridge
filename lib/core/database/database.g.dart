// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ipMeta = const VerificationMeta('ip');
  @override
  late final GeneratedColumn<String> ip = GeneratedColumn<String>(
    'ip',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPairedMeta = const VerificationMeta(
    'isPaired',
  );
  @override
  late final GeneratedColumn<bool> isPaired = GeneratedColumn<bool>(
    'is_paired',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paired" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    platform,
    ip,
    port,
    lastSeen,
    isPaired,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('ip')) {
      context.handle(_ipMeta, ip.isAcceptableOrUnknown(data['ip']!, _ipMeta));
    } else if (isInserting) {
      context.missing(_ipMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    if (data.containsKey('is_paired')) {
      context.handle(
        _isPairedMeta,
        isPaired.isAcceptableOrUnknown(data['is_paired']!, _isPairedMeta),
      );
    } else if (isInserting) {
      context.missing(_isPairedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      ip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ip'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen'],
      )!,
      isPaired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paired'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String name;
  final String platform;
  final String ip;
  final int port;
  final DateTime lastSeen;
  final bool isPaired;
  const Device({
    required this.id,
    required this.name,
    required this.platform,
    required this.ip,
    required this.port,
    required this.lastSeen,
    required this.isPaired,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['platform'] = Variable<String>(platform);
    map['ip'] = Variable<String>(ip);
    map['port'] = Variable<int>(port);
    map['last_seen'] = Variable<DateTime>(lastSeen);
    map['is_paired'] = Variable<bool>(isPaired);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
      platform: Value(platform),
      ip: Value(ip),
      port: Value(port),
      lastSeen: Value(lastSeen),
      isPaired: Value(isPaired),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      platform: serializer.fromJson<String>(json['platform']),
      ip: serializer.fromJson<String>(json['ip']),
      port: serializer.fromJson<int>(json['port']),
      lastSeen: serializer.fromJson<DateTime>(json['lastSeen']),
      isPaired: serializer.fromJson<bool>(json['isPaired']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'platform': serializer.toJson<String>(platform),
      'ip': serializer.toJson<String>(ip),
      'port': serializer.toJson<int>(port),
      'lastSeen': serializer.toJson<DateTime>(lastSeen),
      'isPaired': serializer.toJson<bool>(isPaired),
    };
  }

  Device copyWith({
    String? id,
    String? name,
    String? platform,
    String? ip,
    int? port,
    DateTime? lastSeen,
    bool? isPaired,
  }) => Device(
    id: id ?? this.id,
    name: name ?? this.name,
    platform: platform ?? this.platform,
    ip: ip ?? this.ip,
    port: port ?? this.port,
    lastSeen: lastSeen ?? this.lastSeen,
    isPaired: isPaired ?? this.isPaired,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      platform: data.platform.present ? data.platform.value : this.platform,
      ip: data.ip.present ? data.ip.value : this.ip,
      port: data.port.present ? data.port.value : this.port,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      isPaired: data.isPaired.present ? data.isPaired.value : this.isPaired,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('ip: $ip, ')
          ..write('port: $port, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('isPaired: $isPaired')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, platform, ip, port, lastSeen, isPaired);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.name == this.name &&
          other.platform == this.platform &&
          other.ip == this.ip &&
          other.port == this.port &&
          other.lastSeen == this.lastSeen &&
          other.isPaired == this.isPaired);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> platform;
  final Value<String> ip;
  final Value<int> port;
  final Value<DateTime> lastSeen;
  final Value<bool> isPaired;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.platform = const Value.absent(),
    this.ip = const Value.absent(),
    this.port = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.isPaired = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String name,
    required String platform,
    required String ip,
    required int port,
    required DateTime lastSeen,
    required bool isPaired,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       platform = Value(platform),
       ip = Value(ip),
       port = Value(port),
       lastSeen = Value(lastSeen),
       isPaired = Value(isPaired);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? platform,
    Expression<String>? ip,
    Expression<int>? port,
    Expression<DateTime>? lastSeen,
    Expression<bool>? isPaired,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (platform != null) 'platform': platform,
      if (ip != null) 'ip': ip,
      if (port != null) 'port': port,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (isPaired != null) 'is_paired': isPaired,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? platform,
    Value<String>? ip,
    Value<int>? port,
    Value<DateTime>? lastSeen,
    Value<bool>? isPaired,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      lastSeen: lastSeen ?? this.lastSeen,
      isPaired: isPaired ?? this.isPaired,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (ip.present) {
      map['ip'] = Variable<String>(ip.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (isPaired.present) {
      map['is_paired'] = Variable<bool>(isPaired.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('ip: $ip, ')
          ..write('port: $port, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('isPaired: $isPaired, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransfersTable extends Transfers
    with TableInfo<$TransfersTable, Transfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    fileName,
    fileSize,
    direction,
    status,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transfer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transfer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $TransfersTable createAlias(String alias) {
    return $TransfersTable(attachedDatabase, alias);
  }
}

class Transfer extends DataClass implements Insertable<Transfer> {
  final String id;
  final String deviceId;
  final String fileName;
  final int fileSize;
  final String direction;
  final String status;
  final DateTime timestamp;
  const Transfer({
    required this.id,
    required this.deviceId,
    required this.fileName,
    required this.fileSize,
    required this.direction,
    required this.status,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['file_name'] = Variable<String>(fileName);
    map['file_size'] = Variable<int>(fileSize);
    map['direction'] = Variable<String>(direction);
    map['status'] = Variable<String>(status);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  TransfersCompanion toCompanion(bool nullToAbsent) {
    return TransfersCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      fileName: Value(fileName),
      fileSize: Value(fileSize),
      direction: Value(direction),
      status: Value(status),
      timestamp: Value(timestamp),
    );
  }

  factory Transfer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transfer(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      direction: serializer.fromJson<String>(json['direction']),
      status: serializer.fromJson<String>(json['status']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'fileName': serializer.toJson<String>(fileName),
      'fileSize': serializer.toJson<int>(fileSize),
      'direction': serializer.toJson<String>(direction),
      'status': serializer.toJson<String>(status),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  Transfer copyWith({
    String? id,
    String? deviceId,
    String? fileName,
    int? fileSize,
    String? direction,
    String? status,
    DateTime? timestamp,
  }) => Transfer(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    fileName: fileName ?? this.fileName,
    fileSize: fileSize ?? this.fileSize,
    direction: direction ?? this.direction,
    status: status ?? this.status,
    timestamp: timestamp ?? this.timestamp,
  );
  Transfer copyWithCompanion(TransfersCompanion data) {
    return Transfer(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      direction: data.direction.present ? data.direction.value : this.direction,
      status: data.status.present ? data.status.value : this.status,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transfer(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    fileName,
    fileSize,
    direction,
    status,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transfer &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.direction == this.direction &&
          other.status == this.status &&
          other.timestamp == this.timestamp);
}

class TransfersCompanion extends UpdateCompanion<Transfer> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<String> fileName;
  final Value<int> fileSize;
  final Value<String> direction;
  final Value<String> status;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const TransfersCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.direction = const Value.absent(),
    this.status = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransfersCompanion.insert({
    required String id,
    required String deviceId,
    required String fileName,
    required int fileSize,
    required String direction,
    required String status,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       fileName = Value(fileName),
       fileSize = Value(fileSize),
       direction = Value(direction),
       status = Value(status),
       timestamp = Value(timestamp);
  static Insertable<Transfer> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<String>? direction,
    Expression<String>? status,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (direction != null) 'direction': direction,
      if (status != null) 'status': status,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransfersCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<String>? fileName,
    Value<int>? fileSize,
    Value<String>? direction,
    Value<String>? status,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return TransfersCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransfersCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, Notification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appMeta = const VerificationMeta('app');
  @override
  late final GeneratedColumn<String> app = GeneratedColumn<String>(
    'app',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dismissedMeta = const VerificationMeta(
    'dismissed',
  );
  @override
  late final GeneratedColumn<bool> dismissed = GeneratedColumn<bool>(
    'dismissed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dismissed" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    app,
    title,
    body,
    timestamp,
    dismissed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('app')) {
      context.handle(
        _appMeta,
        app.isAcceptableOrUnknown(data['app']!, _appMeta),
      );
    } else if (isInserting) {
      context.missing(_appMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('dismissed')) {
      context.handle(
        _dismissedMeta,
        dismissed.isAcceptableOrUnknown(data['dismissed']!, _dismissedMeta),
      );
    } else if (isInserting) {
      context.missing(_dismissedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      app: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      dismissed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dismissed'],
      )!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class Notification extends DataClass implements Insertable<Notification> {
  final String id;
  final String deviceId;
  final String app;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool dismissed;
  const Notification({
    required this.id,
    required this.deviceId,
    required this.app,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.dismissed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['app'] = Variable<String>(app);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['dismissed'] = Variable<bool>(dismissed);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      app: Value(app),
      title: Value(title),
      body: Value(body),
      timestamp: Value(timestamp),
      dismissed: Value(dismissed),
    );
  }

  factory Notification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notification(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      app: serializer.fromJson<String>(json['app']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      dismissed: serializer.fromJson<bool>(json['dismissed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'app': serializer.toJson<String>(app),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'dismissed': serializer.toJson<bool>(dismissed),
    };
  }

  Notification copyWith({
    String? id,
    String? deviceId,
    String? app,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? dismissed,
  }) => Notification(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    app: app ?? this.app,
    title: title ?? this.title,
    body: body ?? this.body,
    timestamp: timestamp ?? this.timestamp,
    dismissed: dismissed ?? this.dismissed,
  );
  Notification copyWithCompanion(NotificationsCompanion data) {
    return Notification(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      app: data.app.present ? data.app.value : this.app,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      dismissed: data.dismissed.present ? data.dismissed.value : this.dismissed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notification(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('app: $app, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('timestamp: $timestamp, ')
          ..write('dismissed: $dismissed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, app, title, body, timestamp, dismissed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.app == this.app &&
          other.title == this.title &&
          other.body == this.body &&
          other.timestamp == this.timestamp &&
          other.dismissed == this.dismissed);
}

class NotificationsCompanion extends UpdateCompanion<Notification> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<String> app;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> timestamp;
  final Value<bool> dismissed;
  final Value<int> rowid;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.app = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.dismissed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsCompanion.insert({
    required String id,
    required String deviceId,
    required String app,
    required String title,
    required String body,
    required DateTime timestamp,
    required bool dismissed,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       app = Value(app),
       title = Value(title),
       body = Value(body),
       timestamp = Value(timestamp),
       dismissed = Value(dismissed);
  static Insertable<Notification> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<String>? app,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? timestamp,
    Expression<bool>? dismissed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (app != null) 'app': app,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (timestamp != null) 'timestamp': timestamp,
      if (dismissed != null) 'dismissed': dismissed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<String>? app,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? timestamp,
    Value<bool>? dismissed,
    Value<int>? rowid,
  }) {
    return NotificationsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      app: app ?? this.app,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      dismissed: dismissed ?? this.dismissed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (app.present) {
      map['app'] = Variable<String>(app.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (dismissed.present) {
      map['dismissed'] = Variable<bool>(dismissed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('app: $app, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('timestamp: $timestamp, ')
          ..write('dismissed: $dismissed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readStatusMeta = const VerificationMeta(
    'readStatus',
  );
  @override
  late final GeneratedColumn<bool> readStatus = GeneratedColumn<bool>(
    'read_status',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read_status" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    address,
    body,
    direction,
    timestamp,
    readStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('read_status')) {
      context.handle(
        _readStatusMeta,
        readStatus.isAcceptableOrUnknown(data['read_status']!, _readStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_readStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      readStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read_status'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String deviceId;
  final String address;
  final String body;
  final String direction;
  final DateTime timestamp;
  final bool readStatus;
  const Message({
    required this.id,
    required this.deviceId,
    required this.address,
    required this.body,
    required this.direction,
    required this.timestamp,
    required this.readStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['address'] = Variable<String>(address);
    map['body'] = Variable<String>(body);
    map['direction'] = Variable<String>(direction);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['read_status'] = Variable<bool>(readStatus);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      address: Value(address),
      body: Value(body),
      direction: Value(direction),
      timestamp: Value(timestamp),
      readStatus: Value(readStatus),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      address: serializer.fromJson<String>(json['address']),
      body: serializer.fromJson<String>(json['body']),
      direction: serializer.fromJson<String>(json['direction']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      readStatus: serializer.fromJson<bool>(json['readStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'address': serializer.toJson<String>(address),
      'body': serializer.toJson<String>(body),
      'direction': serializer.toJson<String>(direction),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'readStatus': serializer.toJson<bool>(readStatus),
    };
  }

  Message copyWith({
    String? id,
    String? deviceId,
    String? address,
    String? body,
    String? direction,
    DateTime? timestamp,
    bool? readStatus,
  }) => Message(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    address: address ?? this.address,
    body: body ?? this.body,
    direction: direction ?? this.direction,
    timestamp: timestamp ?? this.timestamp,
    readStatus: readStatus ?? this.readStatus,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      address: data.address.present ? data.address.value : this.address,
      body: data.body.present ? data.body.value : this.body,
      direction: data.direction.present ? data.direction.value : this.direction,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      readStatus: data.readStatus.present
          ? data.readStatus.value
          : this.readStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('address: $address, ')
          ..write('body: $body, ')
          ..write('direction: $direction, ')
          ..write('timestamp: $timestamp, ')
          ..write('readStatus: $readStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    address,
    body,
    direction,
    timestamp,
    readStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.address == this.address &&
          other.body == this.body &&
          other.direction == this.direction &&
          other.timestamp == this.timestamp &&
          other.readStatus == this.readStatus);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<String> address;
  final Value<String> body;
  final Value<String> direction;
  final Value<DateTime> timestamp;
  final Value<bool> readStatus;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.address = const Value.absent(),
    this.body = const Value.absent(),
    this.direction = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.readStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String deviceId,
    required String address,
    required String body,
    required String direction,
    required DateTime timestamp,
    required bool readStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       address = Value(address),
       body = Value(body),
       direction = Value(direction),
       timestamp = Value(timestamp),
       readStatus = Value(readStatus);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<String>? address,
    Expression<String>? body,
    Expression<String>? direction,
    Expression<DateTime>? timestamp,
    Expression<bool>? readStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (address != null) 'address': address,
      if (body != null) 'body': body,
      if (direction != null) 'direction': direction,
      if (timestamp != null) 'timestamp': timestamp,
      if (readStatus != null) 'read_status': readStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<String>? address,
    Value<String>? body,
    Value<String>? direction,
    Value<DateTime>? timestamp,
    Value<bool>? readStatus,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      address: address ?? this.address,
      body: body ?? this.body,
      direction: direction ?? this.direction,
      timestamp: timestamp ?? this.timestamp,
      readStatus: readStatus ?? this.readStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (readStatus.present) {
      map['read_status'] = Variable<bool>(readStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('address: $address, ')
          ..write('body: $body, ')
          ..write('direction: $direction, ')
          ..write('timestamp: $timestamp, ')
          ..write('readStatus: $readStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BridgeDatabase extends GeneratedDatabase {
  _$BridgeDatabase(QueryExecutor e) : super(e);
  $BridgeDatabaseManager get managers => $BridgeDatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $TransfersTable transfers = $TransfersTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devices,
    transfers,
    notifications,
    messages,
    settings,
  ];
}

typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      required String id,
      required String name,
      required String platform,
      required String ip,
      required int port,
      required DateTime lastSeen,
      required bool isPaired,
      Value<int> rowid,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> platform,
      Value<String> ip,
      Value<int> port,
      Value<DateTime> lastSeen,
      Value<bool> isPaired,
      Value<int> rowid,
    });

class $$DevicesTableFilterComposer
    extends Composer<_$BridgeDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ip => $composableBuilder(
    column: $table.ip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaired => $composableBuilder(
    column: $table.isPaired,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$BridgeDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ip => $composableBuilder(
    column: $table.ip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaired => $composableBuilder(
    column: $table.isPaired,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$BridgeDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get ip =>
      $composableBuilder(column: $table.ip, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<bool> get isPaired =>
      $composableBuilder(column: $table.isPaired, builder: (column) => column);
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$BridgeDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, BaseReferences<_$BridgeDatabase, $DevicesTable, Device>),
          Device,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$BridgeDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> ip = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<DateTime> lastSeen = const Value.absent(),
                Value<bool> isPaired = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                name: name,
                platform: platform,
                ip: ip,
                port: port,
                lastSeen: lastSeen,
                isPaired: isPaired,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String platform,
                required String ip,
                required int port,
                required DateTime lastSeen,
                required bool isPaired,
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                name: name,
                platform: platform,
                ip: ip,
                port: port,
                lastSeen: lastSeen,
                isPaired: isPaired,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgeDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, BaseReferences<_$BridgeDatabase, $DevicesTable, Device>),
      Device,
      PrefetchHooks Function()
    >;
typedef $$TransfersTableCreateCompanionBuilder =
    TransfersCompanion Function({
      required String id,
      required String deviceId,
      required String fileName,
      required int fileSize,
      required String direction,
      required String status,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$TransfersTableUpdateCompanionBuilder =
    TransfersCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<String> fileName,
      Value<int> fileSize,
      Value<String> direction,
      Value<String> status,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$TransfersTableFilterComposer
    extends Composer<_$BridgeDatabase, $TransfersTable> {
  $$TransfersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransfersTableOrderingComposer
    extends Composer<_$BridgeDatabase, $TransfersTable> {
  $$TransfersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransfersTableAnnotationComposer
    extends Composer<_$BridgeDatabase, $TransfersTable> {
  $$TransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$TransfersTableTableManager
    extends
        RootTableManager<
          _$BridgeDatabase,
          $TransfersTable,
          Transfer,
          $$TransfersTableFilterComposer,
          $$TransfersTableOrderingComposer,
          $$TransfersTableAnnotationComposer,
          $$TransfersTableCreateCompanionBuilder,
          $$TransfersTableUpdateCompanionBuilder,
          (
            Transfer,
            BaseReferences<_$BridgeDatabase, $TransfersTable, Transfer>,
          ),
          Transfer,
          PrefetchHooks Function()
        > {
  $$TransfersTableTableManager(_$BridgeDatabase db, $TransfersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransfersCompanion(
                id: id,
                deviceId: deviceId,
                fileName: fileName,
                fileSize: fileSize,
                direction: direction,
                status: status,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required String fileName,
                required int fileSize,
                required String direction,
                required String status,
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => TransfersCompanion.insert(
                id: id,
                deviceId: deviceId,
                fileName: fileName,
                fileSize: fileSize,
                direction: direction,
                status: status,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgeDatabase,
      $TransfersTable,
      Transfer,
      $$TransfersTableFilterComposer,
      $$TransfersTableOrderingComposer,
      $$TransfersTableAnnotationComposer,
      $$TransfersTableCreateCompanionBuilder,
      $$TransfersTableUpdateCompanionBuilder,
      (Transfer, BaseReferences<_$BridgeDatabase, $TransfersTable, Transfer>),
      Transfer,
      PrefetchHooks Function()
    >;
typedef $$NotificationsTableCreateCompanionBuilder =
    NotificationsCompanion Function({
      required String id,
      required String deviceId,
      required String app,
      required String title,
      required String body,
      required DateTime timestamp,
      required bool dismissed,
      Value<int> rowid,
    });
typedef $$NotificationsTableUpdateCompanionBuilder =
    NotificationsCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<String> app,
      Value<String> title,
      Value<String> body,
      Value<DateTime> timestamp,
      Value<bool> dismissed,
      Value<int> rowid,
    });

class $$NotificationsTableFilterComposer
    extends Composer<_$BridgeDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get app => $composableBuilder(
    column: $table.app,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dismissed => $composableBuilder(
    column: $table.dismissed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$BridgeDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get app => $composableBuilder(
    column: $table.app,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dismissed => $composableBuilder(
    column: $table.dismissed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$BridgeDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get app =>
      $composableBuilder(column: $table.app, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get dismissed =>
      $composableBuilder(column: $table.dismissed, builder: (column) => column);
}

class $$NotificationsTableTableManager
    extends
        RootTableManager<
          _$BridgeDatabase,
          $NotificationsTable,
          Notification,
          $$NotificationsTableFilterComposer,
          $$NotificationsTableOrderingComposer,
          $$NotificationsTableAnnotationComposer,
          $$NotificationsTableCreateCompanionBuilder,
          $$NotificationsTableUpdateCompanionBuilder,
          (
            Notification,
            BaseReferences<_$BridgeDatabase, $NotificationsTable, Notification>,
          ),
          Notification,
          PrefetchHooks Function()
        > {
  $$NotificationsTableTableManager(
    _$BridgeDatabase db,
    $NotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> app = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> dismissed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCompanion(
                id: id,
                deviceId: deviceId,
                app: app,
                title: title,
                body: body,
                timestamp: timestamp,
                dismissed: dismissed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required String app,
                required String title,
                required String body,
                required DateTime timestamp,
                required bool dismissed,
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCompanion.insert(
                id: id,
                deviceId: deviceId,
                app: app,
                title: title,
                body: body,
                timestamp: timestamp,
                dismissed: dismissed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgeDatabase,
      $NotificationsTable,
      Notification,
      $$NotificationsTableFilterComposer,
      $$NotificationsTableOrderingComposer,
      $$NotificationsTableAnnotationComposer,
      $$NotificationsTableCreateCompanionBuilder,
      $$NotificationsTableUpdateCompanionBuilder,
      (
        Notification,
        BaseReferences<_$BridgeDatabase, $NotificationsTable, Notification>,
      ),
      Notification,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String deviceId,
      required String address,
      required String body,
      required String direction,
      required DateTime timestamp,
      required bool readStatus,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<String> address,
      Value<String> body,
      Value<String> direction,
      Value<DateTime> timestamp,
      Value<bool> readStatus,
      Value<int> rowid,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$BridgeDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get readStatus => $composableBuilder(
    column: $table.readStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$BridgeDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get readStatus => $composableBuilder(
    column: $table.readStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$BridgeDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get readStatus => $composableBuilder(
    column: $table.readStatus,
    builder: (column) => column,
  );
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$BridgeDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$BridgeDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$BridgeDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> readStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                deviceId: deviceId,
                address: address,
                body: body,
                direction: direction,
                timestamp: timestamp,
                readStatus: readStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required String address,
                required String body,
                required String direction,
                required DateTime timestamp,
                required bool readStatus,
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                deviceId: deviceId,
                address: address,
                body: body,
                direction: direction,
                timestamp: timestamp,
                readStatus: readStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgeDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$BridgeDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$BridgeDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$BridgeDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$BridgeDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$BridgeDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$BridgeDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$BridgeDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgeDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$BridgeDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $BridgeDatabaseManager {
  final _$BridgeDatabase _db;
  $BridgeDatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$TransfersTableTableManager get transfers =>
      $$TransfersTableTableManager(_db, _db.transfers);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
