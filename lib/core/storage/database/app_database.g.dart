// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, Workspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workspace> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workspace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class Workspace extends DataClass implements Insertable<Workspace> {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Workspace({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Workspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workspace(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Workspace copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Workspace(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Workspace copyWithCompanion(WorkspacesCompanion data) {
    return Workspace(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workspace(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workspace &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkspacesCompanion extends UpdateCompanion<Workspace> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkspacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Workspace> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspacesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkspacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    name,
    description,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final String id;
  final String workspaceId;
  final String name;
  final String? description;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Collection({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Collection copyWith({
    String? id,
    String? workspaceId,
    String? name,
    Value<String?> description = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Collection(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    name,
    description,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.name == this.name &&
          other.description == this.description &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String workspaceId,
    required String name,
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       name = Value(name);
  static Insertable<Collection> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentFolderIdMeta = const VerificationMeta(
    'parentFolderId',
  );
  @override
  late final GeneratedColumn<String> parentFolderId = GeneratedColumn<String>(
    'parent_folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectionId,
    parentFolderId,
    name,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('parent_folder_id')) {
      context.handle(
        _parentFolderIdMeta,
        parentFolderId.isAcceptableOrUnknown(
          data['parent_folder_id']!,
          _parentFolderIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      parentFolderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_folder_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final String id;
  final String collectionId;
  final String? parentFolderId;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  const Folder({
    required this.id,
    required this.collectionId,
    this.parentFolderId,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['collection_id'] = Variable<String>(collectionId);
    if (!nullToAbsent || parentFolderId != null) {
      map['parent_folder_id'] = Variable<String>(parentFolderId);
    }
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      parentFolderId: parentFolderId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentFolderId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<String>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      parentFolderId: serializer.fromJson<String?>(json['parentFolderId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'parentFolderId': serializer.toJson<String?>(parentFolderId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Folder copyWith({
    String? id,
    String? collectionId,
    Value<String?> parentFolderId = const Value.absent(),
    String? name,
    int? sortOrder,
    DateTime? createdAt,
  }) => Folder(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    parentFolderId: parentFolderId.present
        ? parentFolderId.value
        : this.parentFolderId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      parentFolderId: data.parentFolderId.present
          ? data.parentFolderId.value
          : this.parentFolderId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('parentFolderId: $parentFolderId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, collectionId, parentFolderId, name, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.parentFolderId == this.parentFolderId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<String> id;
  final Value<String> collectionId;
  final Value<String?> parentFolderId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.parentFolderId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String id,
    required String collectionId,
    this.parentFolderId = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       collectionId = Value(collectionId),
       name = Value(name);
  static Insertable<Folder> custom({
    Expression<String>? id,
    Expression<String>? collectionId,
    Expression<String>? parentFolderId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (parentFolderId != null) 'parent_folder_id': parentFolderId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? collectionId,
    Value<String?>? parentFolderId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (parentFolderId.present) {
      map['parent_folder_id'] = Variable<String>(parentFolderId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('parentFolderId: $parentFolderId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedRequestsTable extends SavedRequests
    with TableInfo<$SavedRequestsTable, SavedRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queryParamsJsonMeta = const VerificationMeta(
    'queryParamsJson',
  );
  @override
  late final GeneratedColumn<String> queryParamsJson = GeneratedColumn<String>(
    'query_params_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _headersJsonMeta = const VerificationMeta(
    'headersJson',
  );
  @override
  late final GeneratedColumn<String> headersJson = GeneratedColumn<String>(
    'headers_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _bodyTypeMeta = const VerificationMeta(
    'bodyType',
  );
  @override
  late final GeneratedColumn<String> bodyType = GeneratedColumn<String>(
    'body_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _bodyContentMeta = const VerificationMeta(
    'bodyContent',
  );
  @override
  late final GeneratedColumn<String> bodyContent = GeneratedColumn<String>(
    'body_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _formDataJsonMeta = const VerificationMeta(
    'formDataJson',
  );
  @override
  late final GeneratedColumn<String> formDataJson = GeneratedColumn<String>(
    'form_data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _authTypeMeta = const VerificationMeta(
    'authType',
  );
  @override
  late final GeneratedColumn<String> authType = GeneratedColumn<String>(
    'auth_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _authConfigJsonMeta = const VerificationMeta(
    'authConfigJson',
  );
  @override
  late final GeneratedColumn<String> authConfigJson = GeneratedColumn<String>(
    'auth_config_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectionId,
    folderId,
    name,
    description,
    method,
    url,
    queryParamsJson,
    headersJson,
    bodyType,
    bodyContent,
    formDataJson,
    authType,
    authConfigJson,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('query_params_json')) {
      context.handle(
        _queryParamsJsonMeta,
        queryParamsJson.isAcceptableOrUnknown(
          data['query_params_json']!,
          _queryParamsJsonMeta,
        ),
      );
    }
    if (data.containsKey('headers_json')) {
      context.handle(
        _headersJsonMeta,
        headersJson.isAcceptableOrUnknown(
          data['headers_json']!,
          _headersJsonMeta,
        ),
      );
    }
    if (data.containsKey('body_type')) {
      context.handle(
        _bodyTypeMeta,
        bodyType.isAcceptableOrUnknown(data['body_type']!, _bodyTypeMeta),
      );
    }
    if (data.containsKey('body_content')) {
      context.handle(
        _bodyContentMeta,
        bodyContent.isAcceptableOrUnknown(
          data['body_content']!,
          _bodyContentMeta,
        ),
      );
    }
    if (data.containsKey('form_data_json')) {
      context.handle(
        _formDataJsonMeta,
        formDataJson.isAcceptableOrUnknown(
          data['form_data_json']!,
          _formDataJsonMeta,
        ),
      );
    }
    if (data.containsKey('auth_type')) {
      context.handle(
        _authTypeMeta,
        authType.isAcceptableOrUnknown(data['auth_type']!, _authTypeMeta),
      );
    }
    if (data.containsKey('auth_config_json')) {
      context.handle(
        _authConfigJsonMeta,
        authConfigJson.isAcceptableOrUnknown(
          data['auth_config_json']!,
          _authConfigJsonMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      queryParamsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query_params_json'],
      )!,
      headersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers_json'],
      )!,
      bodyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_type'],
      )!,
      bodyContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_content'],
      )!,
      formDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_data_json'],
      )!,
      authType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_type'],
      )!,
      authConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_config_json'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SavedRequestsTable createAlias(String alias) {
    return $SavedRequestsTable(attachedDatabase, alias);
  }
}

class SavedRequest extends DataClass implements Insertable<SavedRequest> {
  final String id;
  final String collectionId;
  final String? folderId;
  final String name;
  final String? description;
  final String method;
  final String url;
  final String queryParamsJson;
  final String headersJson;
  final String bodyType;
  final String bodyContent;
  final String formDataJson;
  final String authType;
  final String? authConfigJson;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SavedRequest({
    required this.id,
    required this.collectionId,
    this.folderId,
    required this.name,
    this.description,
    required this.method,
    required this.url,
    required this.queryParamsJson,
    required this.headersJson,
    required this.bodyType,
    required this.bodyContent,
    required this.formDataJson,
    required this.authType,
    this.authConfigJson,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['collection_id'] = Variable<String>(collectionId);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['method'] = Variable<String>(method);
    map['url'] = Variable<String>(url);
    map['query_params_json'] = Variable<String>(queryParamsJson);
    map['headers_json'] = Variable<String>(headersJson);
    map['body_type'] = Variable<String>(bodyType);
    map['body_content'] = Variable<String>(bodyContent);
    map['form_data_json'] = Variable<String>(formDataJson);
    map['auth_type'] = Variable<String>(authType);
    if (!nullToAbsent || authConfigJson != null) {
      map['auth_config_json'] = Variable<String>(authConfigJson);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SavedRequestsCompanion toCompanion(bool nullToAbsent) {
    return SavedRequestsCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      method: Value(method),
      url: Value(url),
      queryParamsJson: Value(queryParamsJson),
      headersJson: Value(headersJson),
      bodyType: Value(bodyType),
      bodyContent: Value(bodyContent),
      formDataJson: Value(formDataJson),
      authType: Value(authType),
      authConfigJson: authConfigJson == null && nullToAbsent
          ? const Value.absent()
          : Value(authConfigJson),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SavedRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedRequest(
      id: serializer.fromJson<String>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      method: serializer.fromJson<String>(json['method']),
      url: serializer.fromJson<String>(json['url']),
      queryParamsJson: serializer.fromJson<String>(json['queryParamsJson']),
      headersJson: serializer.fromJson<String>(json['headersJson']),
      bodyType: serializer.fromJson<String>(json['bodyType']),
      bodyContent: serializer.fromJson<String>(json['bodyContent']),
      formDataJson: serializer.fromJson<String>(json['formDataJson']),
      authType: serializer.fromJson<String>(json['authType']),
      authConfigJson: serializer.fromJson<String?>(json['authConfigJson']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'folderId': serializer.toJson<String?>(folderId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'method': serializer.toJson<String>(method),
      'url': serializer.toJson<String>(url),
      'queryParamsJson': serializer.toJson<String>(queryParamsJson),
      'headersJson': serializer.toJson<String>(headersJson),
      'bodyType': serializer.toJson<String>(bodyType),
      'bodyContent': serializer.toJson<String>(bodyContent),
      'formDataJson': serializer.toJson<String>(formDataJson),
      'authType': serializer.toJson<String>(authType),
      'authConfigJson': serializer.toJson<String?>(authConfigJson),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SavedRequest copyWith({
    String? id,
    String? collectionId,
    Value<String?> folderId = const Value.absent(),
    String? name,
    Value<String?> description = const Value.absent(),
    String? method,
    String? url,
    String? queryParamsJson,
    String? headersJson,
    String? bodyType,
    String? bodyContent,
    String? formDataJson,
    String? authType,
    Value<String?> authConfigJson = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SavedRequest(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    folderId: folderId.present ? folderId.value : this.folderId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    method: method ?? this.method,
    url: url ?? this.url,
    queryParamsJson: queryParamsJson ?? this.queryParamsJson,
    headersJson: headersJson ?? this.headersJson,
    bodyType: bodyType ?? this.bodyType,
    bodyContent: bodyContent ?? this.bodyContent,
    formDataJson: formDataJson ?? this.formDataJson,
    authType: authType ?? this.authType,
    authConfigJson: authConfigJson.present
        ? authConfigJson.value
        : this.authConfigJson,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SavedRequest copyWithCompanion(SavedRequestsCompanion data) {
    return SavedRequest(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      method: data.method.present ? data.method.value : this.method,
      url: data.url.present ? data.url.value : this.url,
      queryParamsJson: data.queryParamsJson.present
          ? data.queryParamsJson.value
          : this.queryParamsJson,
      headersJson: data.headersJson.present
          ? data.headersJson.value
          : this.headersJson,
      bodyType: data.bodyType.present ? data.bodyType.value : this.bodyType,
      bodyContent: data.bodyContent.present
          ? data.bodyContent.value
          : this.bodyContent,
      formDataJson: data.formDataJson.present
          ? data.formDataJson.value
          : this.formDataJson,
      authType: data.authType.present ? data.authType.value : this.authType,
      authConfigJson: data.authConfigJson.present
          ? data.authConfigJson.value
          : this.authConfigJson,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedRequest(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('folderId: $folderId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('queryParamsJson: $queryParamsJson, ')
          ..write('headersJson: $headersJson, ')
          ..write('bodyType: $bodyType, ')
          ..write('bodyContent: $bodyContent, ')
          ..write('formDataJson: $formDataJson, ')
          ..write('authType: $authType, ')
          ..write('authConfigJson: $authConfigJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    collectionId,
    folderId,
    name,
    description,
    method,
    url,
    queryParamsJson,
    headersJson,
    bodyType,
    bodyContent,
    formDataJson,
    authType,
    authConfigJson,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedRequest &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.folderId == this.folderId &&
          other.name == this.name &&
          other.description == this.description &&
          other.method == this.method &&
          other.url == this.url &&
          other.queryParamsJson == this.queryParamsJson &&
          other.headersJson == this.headersJson &&
          other.bodyType == this.bodyType &&
          other.bodyContent == this.bodyContent &&
          other.formDataJson == this.formDataJson &&
          other.authType == this.authType &&
          other.authConfigJson == this.authConfigJson &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SavedRequestsCompanion extends UpdateCompanion<SavedRequest> {
  final Value<String> id;
  final Value<String> collectionId;
  final Value<String?> folderId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> method;
  final Value<String> url;
  final Value<String> queryParamsJson;
  final Value<String> headersJson;
  final Value<String> bodyType;
  final Value<String> bodyContent;
  final Value<String> formDataJson;
  final Value<String> authType;
  final Value<String?> authConfigJson;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SavedRequestsCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.method = const Value.absent(),
    this.url = const Value.absent(),
    this.queryParamsJson = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.bodyType = const Value.absent(),
    this.bodyContent = const Value.absent(),
    this.formDataJson = const Value.absent(),
    this.authType = const Value.absent(),
    this.authConfigJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedRequestsCompanion.insert({
    required String id,
    required String collectionId,
    this.folderId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required String method,
    required String url,
    this.queryParamsJson = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.bodyType = const Value.absent(),
    this.bodyContent = const Value.absent(),
    this.formDataJson = const Value.absent(),
    this.authType = const Value.absent(),
    this.authConfigJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       collectionId = Value(collectionId),
       name = Value(name),
       method = Value(method),
       url = Value(url);
  static Insertable<SavedRequest> custom({
    Expression<String>? id,
    Expression<String>? collectionId,
    Expression<String>? folderId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? method,
    Expression<String>? url,
    Expression<String>? queryParamsJson,
    Expression<String>? headersJson,
    Expression<String>? bodyType,
    Expression<String>? bodyContent,
    Expression<String>? formDataJson,
    Expression<String>? authType,
    Expression<String>? authConfigJson,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (folderId != null) 'folder_id': folderId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (method != null) 'method': method,
      if (url != null) 'url': url,
      if (queryParamsJson != null) 'query_params_json': queryParamsJson,
      if (headersJson != null) 'headers_json': headersJson,
      if (bodyType != null) 'body_type': bodyType,
      if (bodyContent != null) 'body_content': bodyContent,
      if (formDataJson != null) 'form_data_json': formDataJson,
      if (authType != null) 'auth_type': authType,
      if (authConfigJson != null) 'auth_config_json': authConfigJson,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? collectionId,
    Value<String?>? folderId,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? method,
    Value<String>? url,
    Value<String>? queryParamsJson,
    Value<String>? headersJson,
    Value<String>? bodyType,
    Value<String>? bodyContent,
    Value<String>? formDataJson,
    Value<String>? authType,
    Value<String?>? authConfigJson,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SavedRequestsCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      folderId: folderId ?? this.folderId,
      name: name ?? this.name,
      description: description ?? this.description,
      method: method ?? this.method,
      url: url ?? this.url,
      queryParamsJson: queryParamsJson ?? this.queryParamsJson,
      headersJson: headersJson ?? this.headersJson,
      bodyType: bodyType ?? this.bodyType,
      bodyContent: bodyContent ?? this.bodyContent,
      formDataJson: formDataJson ?? this.formDataJson,
      authType: authType ?? this.authType,
      authConfigJson: authConfigJson ?? this.authConfigJson,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (queryParamsJson.present) {
      map['query_params_json'] = Variable<String>(queryParamsJson.value);
    }
    if (headersJson.present) {
      map['headers_json'] = Variable<String>(headersJson.value);
    }
    if (bodyType.present) {
      map['body_type'] = Variable<String>(bodyType.value);
    }
    if (bodyContent.present) {
      map['body_content'] = Variable<String>(bodyContent.value);
    }
    if (formDataJson.present) {
      map['form_data_json'] = Variable<String>(formDataJson.value);
    }
    if (authType.present) {
      map['auth_type'] = Variable<String>(authType.value);
    }
    if (authConfigJson.present) {
      map['auth_config_json'] = Variable<String>(authConfigJson.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedRequestsCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('folderId: $folderId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('queryParamsJson: $queryParamsJson, ')
          ..write('headersJson: $headersJson, ')
          ..write('bodyType: $bodyType, ')
          ..write('bodyContent: $bodyContent, ')
          ..write('formDataJson: $formDataJson, ')
          ..write('authType: $authType, ')
          ..write('authConfigJson: $authConfigJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnvironmentsTable extends Environments
    with TableInfo<$EnvironmentsTable, Environment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvironmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0xFF10B981'),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    name,
    colorHex,
    isDefault,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'environments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Environment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Environment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Environment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EnvironmentsTable createAlias(String alias) {
    return $EnvironmentsTable(attachedDatabase, alias);
  }
}

class Environment extends DataClass implements Insertable<Environment> {
  final String id;
  final String workspaceId;
  final String name;
  final String colorHex;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Environment({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.colorHex,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EnvironmentsCompanion toCompanion(bool nullToAbsent) {
    return EnvironmentsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      name: Value(name),
      colorHex: Value(colorHex),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Environment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Environment(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Environment copyWith({
    String? id,
    String? workspaceId,
    String? name,
    String? colorHex,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Environment(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Environment copyWithCompanion(EnvironmentsCompanion data) {
    return Environment(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Environment(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    name,
    colorHex,
    isDefault,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Environment &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EnvironmentsCompanion extends UpdateCompanion<Environment> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EnvironmentsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnvironmentsCompanion.insert({
    required String id,
    required String workspaceId,
    required String name,
    this.colorHex = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       name = Value(name);
  static Insertable<Environment> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnvironmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? name,
    Value<String>? colorHex,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EnvironmentsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnvironmentVariablesTable extends EnvironmentVariables
    with TableInfo<$EnvironmentVariablesTable, EnvironmentVariable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvironmentVariablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _environmentIdMeta = const VerificationMeta(
    'environmentId',
  );
  @override
  late final GeneratedColumn<String> environmentId = GeneratedColumn<String>(
    'environment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isSecretMeta = const VerificationMeta(
    'isSecret',
  );
  @override
  late final GeneratedColumn<bool> isSecret = GeneratedColumn<bool>(
    'is_secret',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_secret" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _secretRefIdMeta = const VerificationMeta(
    'secretRefId',
  );
  @override
  late final GeneratedColumn<String> secretRefId = GeneratedColumn<String>(
    'secret_ref_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    environmentId,
    key,
    value,
    isSecret,
    secretRefId,
    isEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'environment_variables';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvironmentVariable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('environment_id')) {
      context.handle(
        _environmentIdMeta,
        environmentId.isAcceptableOrUnknown(
          data['environment_id']!,
          _environmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_environmentIdMeta);
    }
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
    }
    if (data.containsKey('is_secret')) {
      context.handle(
        _isSecretMeta,
        isSecret.isAcceptableOrUnknown(data['is_secret']!, _isSecretMeta),
      );
    }
    if (data.containsKey('secret_ref_id')) {
      context.handle(
        _secretRefIdMeta,
        secretRefId.isAcceptableOrUnknown(
          data['secret_ref_id']!,
          _secretRefIdMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnvironmentVariable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvironmentVariable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      environmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}environment_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      isSecret: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_secret'],
      )!,
      secretRefId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secret_ref_id'],
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
    );
  }

  @override
  $EnvironmentVariablesTable createAlias(String alias) {
    return $EnvironmentVariablesTable(attachedDatabase, alias);
  }
}

class EnvironmentVariable extends DataClass
    implements Insertable<EnvironmentVariable> {
  final String id;
  final String environmentId;
  final String key;
  final String value;
  final bool isSecret;
  final String? secretRefId;
  final bool isEnabled;
  const EnvironmentVariable({
    required this.id,
    required this.environmentId,
    required this.key,
    required this.value,
    required this.isSecret,
    this.secretRefId,
    required this.isEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['environment_id'] = Variable<String>(environmentId);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['is_secret'] = Variable<bool>(isSecret);
    if (!nullToAbsent || secretRefId != null) {
      map['secret_ref_id'] = Variable<String>(secretRefId);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    return map;
  }

  EnvironmentVariablesCompanion toCompanion(bool nullToAbsent) {
    return EnvironmentVariablesCompanion(
      id: Value(id),
      environmentId: Value(environmentId),
      key: Value(key),
      value: Value(value),
      isSecret: Value(isSecret),
      secretRefId: secretRefId == null && nullToAbsent
          ? const Value.absent()
          : Value(secretRefId),
      isEnabled: Value(isEnabled),
    );
  }

  factory EnvironmentVariable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvironmentVariable(
      id: serializer.fromJson<String>(json['id']),
      environmentId: serializer.fromJson<String>(json['environmentId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      isSecret: serializer.fromJson<bool>(json['isSecret']),
      secretRefId: serializer.fromJson<String?>(json['secretRefId']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'environmentId': serializer.toJson<String>(environmentId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'isSecret': serializer.toJson<bool>(isSecret),
      'secretRefId': serializer.toJson<String?>(secretRefId),
      'isEnabled': serializer.toJson<bool>(isEnabled),
    };
  }

  EnvironmentVariable copyWith({
    String? id,
    String? environmentId,
    String? key,
    String? value,
    bool? isSecret,
    Value<String?> secretRefId = const Value.absent(),
    bool? isEnabled,
  }) => EnvironmentVariable(
    id: id ?? this.id,
    environmentId: environmentId ?? this.environmentId,
    key: key ?? this.key,
    value: value ?? this.value,
    isSecret: isSecret ?? this.isSecret,
    secretRefId: secretRefId.present ? secretRefId.value : this.secretRefId,
    isEnabled: isEnabled ?? this.isEnabled,
  );
  EnvironmentVariable copyWithCompanion(EnvironmentVariablesCompanion data) {
    return EnvironmentVariable(
      id: data.id.present ? data.id.value : this.id,
      environmentId: data.environmentId.present
          ? data.environmentId.value
          : this.environmentId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      isSecret: data.isSecret.present ? data.isSecret.value : this.isSecret,
      secretRefId: data.secretRefId.present
          ? data.secretRefId.value
          : this.secretRefId,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentVariable(')
          ..write('id: $id, ')
          ..write('environmentId: $environmentId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('isSecret: $isSecret, ')
          ..write('secretRefId: $secretRefId, ')
          ..write('isEnabled: $isEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    environmentId,
    key,
    value,
    isSecret,
    secretRefId,
    isEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvironmentVariable &&
          other.id == this.id &&
          other.environmentId == this.environmentId &&
          other.key == this.key &&
          other.value == this.value &&
          other.isSecret == this.isSecret &&
          other.secretRefId == this.secretRefId &&
          other.isEnabled == this.isEnabled);
}

class EnvironmentVariablesCompanion
    extends UpdateCompanion<EnvironmentVariable> {
  final Value<String> id;
  final Value<String> environmentId;
  final Value<String> key;
  final Value<String> value;
  final Value<bool> isSecret;
  final Value<String?> secretRefId;
  final Value<bool> isEnabled;
  final Value<int> rowid;
  const EnvironmentVariablesCompanion({
    this.id = const Value.absent(),
    this.environmentId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.isSecret = const Value.absent(),
    this.secretRefId = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnvironmentVariablesCompanion.insert({
    required String id,
    required String environmentId,
    required String key,
    this.value = const Value.absent(),
    this.isSecret = const Value.absent(),
    this.secretRefId = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       environmentId = Value(environmentId),
       key = Value(key);
  static Insertable<EnvironmentVariable> custom({
    Expression<String>? id,
    Expression<String>? environmentId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<bool>? isSecret,
    Expression<String>? secretRefId,
    Expression<bool>? isEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (environmentId != null) 'environment_id': environmentId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (isSecret != null) 'is_secret': isSecret,
      if (secretRefId != null) 'secret_ref_id': secretRefId,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnvironmentVariablesCompanion copyWith({
    Value<String>? id,
    Value<String>? environmentId,
    Value<String>? key,
    Value<String>? value,
    Value<bool>? isSecret,
    Value<String?>? secretRefId,
    Value<bool>? isEnabled,
    Value<int>? rowid,
  }) {
    return EnvironmentVariablesCompanion(
      id: id ?? this.id,
      environmentId: environmentId ?? this.environmentId,
      key: key ?? this.key,
      value: value ?? this.value,
      isSecret: isSecret ?? this.isSecret,
      secretRefId: secretRefId ?? this.secretRefId,
      isEnabled: isEnabled ?? this.isEnabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (environmentId.present) {
      map['environment_id'] = Variable<String>(environmentId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (isSecret.present) {
      map['is_secret'] = Variable<bool>(isSecret.value);
    }
    if (secretRefId.present) {
      map['secret_ref_id'] = Variable<String>(secretRefId.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentVariablesCompanion(')
          ..write('id: $id, ')
          ..write('environmentId: $environmentId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('isSecret: $isSecret, ')
          ..write('secretRefId: $secretRefId, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestHistoryEntriesTable extends RequestHistoryEntries
    with TableInfo<$RequestHistoryEntriesTable, RequestHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusCodeMeta = const VerificationMeta(
    'statusCode',
  );
  @override
  late final GeneratedColumn<int> statusCode = GeneratedColumn<int>(
    'status_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMessageMeta = const VerificationMeta(
    'statusMessage',
  );
  @override
  late final GeneratedColumn<String> statusMessage = GeneratedColumn<String>(
    'status_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentLengthBytesMeta =
      const VerificationMeta('contentLengthBytes');
  @override
  late final GeneratedColumn<int> contentLengthBytes = GeneratedColumn<int>(
    'content_length_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _headersJsonMeta = const VerificationMeta(
    'headersJson',
  );
  @override
  late final GeneratedColumn<String> headersJson = GeneratedColumn<String>(
    'headers_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _responseHeadersJsonMeta =
      const VerificationMeta('responseHeadersJson');
  @override
  late final GeneratedColumn<String> responseHeadersJson =
      GeneratedColumn<String>(
        'response_headers_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _bodyContentMeta = const VerificationMeta(
    'bodyContent',
  );
  @override
  late final GeneratedColumn<String> bodyContent = GeneratedColumn<String>(
    'body_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _executedAtMeta = const VerificationMeta(
    'executedAt',
  );
  @override
  late final GeneratedColumn<DateTime> executedAt = GeneratedColumn<DateTime>(
    'executed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    method,
    url,
    statusCode,
    statusMessage,
    durationMs,
    contentLengthBytes,
    headersJson,
    responseHeadersJson,
    bodyContent,
    executedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'request_history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<RequestHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('status_code')) {
      context.handle(
        _statusCodeMeta,
        statusCode.isAcceptableOrUnknown(data['status_code']!, _statusCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_statusCodeMeta);
    }
    if (data.containsKey('status_message')) {
      context.handle(
        _statusMessageMeta,
        statusMessage.isAcceptableOrUnknown(
          data['status_message']!,
          _statusMessageMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('content_length_bytes')) {
      context.handle(
        _contentLengthBytesMeta,
        contentLengthBytes.isAcceptableOrUnknown(
          data['content_length_bytes']!,
          _contentLengthBytesMeta,
        ),
      );
    }
    if (data.containsKey('headers_json')) {
      context.handle(
        _headersJsonMeta,
        headersJson.isAcceptableOrUnknown(
          data['headers_json']!,
          _headersJsonMeta,
        ),
      );
    }
    if (data.containsKey('response_headers_json')) {
      context.handle(
        _responseHeadersJsonMeta,
        responseHeadersJson.isAcceptableOrUnknown(
          data['response_headers_json']!,
          _responseHeadersJsonMeta,
        ),
      );
    }
    if (data.containsKey('body_content')) {
      context.handle(
        _bodyContentMeta,
        bodyContent.isAcceptableOrUnknown(
          data['body_content']!,
          _bodyContentMeta,
        ),
      );
    }
    if (data.containsKey('executed_at')) {
      context.handle(
        _executedAtMeta,
        executedAt.isAcceptableOrUnknown(data['executed_at']!, _executedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RequestHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RequestHistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      statusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status_code'],
      )!,
      statusMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_message'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      contentLengthBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_length_bytes'],
      )!,
      headersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers_json'],
      )!,
      responseHeadersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_headers_json'],
      )!,
      bodyContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_content'],
      ),
      executedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}executed_at'],
      )!,
    );
  }

  @override
  $RequestHistoryEntriesTable createAlias(String alias) {
    return $RequestHistoryEntriesTable(attachedDatabase, alias);
  }
}

class RequestHistoryEntry extends DataClass
    implements Insertable<RequestHistoryEntry> {
  final String id;
  final String method;
  final String url;
  final int statusCode;
  final String statusMessage;
  final int durationMs;
  final int contentLengthBytes;
  final String headersJson;
  final String responseHeadersJson;
  final String? bodyContent;
  final DateTime executedAt;
  const RequestHistoryEntry({
    required this.id,
    required this.method,
    required this.url,
    required this.statusCode,
    required this.statusMessage,
    required this.durationMs,
    required this.contentLengthBytes,
    required this.headersJson,
    required this.responseHeadersJson,
    this.bodyContent,
    required this.executedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['method'] = Variable<String>(method);
    map['url'] = Variable<String>(url);
    map['status_code'] = Variable<int>(statusCode);
    map['status_message'] = Variable<String>(statusMessage);
    map['duration_ms'] = Variable<int>(durationMs);
    map['content_length_bytes'] = Variable<int>(contentLengthBytes);
    map['headers_json'] = Variable<String>(headersJson);
    map['response_headers_json'] = Variable<String>(responseHeadersJson);
    if (!nullToAbsent || bodyContent != null) {
      map['body_content'] = Variable<String>(bodyContent);
    }
    map['executed_at'] = Variable<DateTime>(executedAt);
    return map;
  }

  RequestHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return RequestHistoryEntriesCompanion(
      id: Value(id),
      method: Value(method),
      url: Value(url),
      statusCode: Value(statusCode),
      statusMessage: Value(statusMessage),
      durationMs: Value(durationMs),
      contentLengthBytes: Value(contentLengthBytes),
      headersJson: Value(headersJson),
      responseHeadersJson: Value(responseHeadersJson),
      bodyContent: bodyContent == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyContent),
      executedAt: Value(executedAt),
    );
  }

  factory RequestHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestHistoryEntry(
      id: serializer.fromJson<String>(json['id']),
      method: serializer.fromJson<String>(json['method']),
      url: serializer.fromJson<String>(json['url']),
      statusCode: serializer.fromJson<int>(json['statusCode']),
      statusMessage: serializer.fromJson<String>(json['statusMessage']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      contentLengthBytes: serializer.fromJson<int>(json['contentLengthBytes']),
      headersJson: serializer.fromJson<String>(json['headersJson']),
      responseHeadersJson: serializer.fromJson<String>(
        json['responseHeadersJson'],
      ),
      bodyContent: serializer.fromJson<String?>(json['bodyContent']),
      executedAt: serializer.fromJson<DateTime>(json['executedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'method': serializer.toJson<String>(method),
      'url': serializer.toJson<String>(url),
      'statusCode': serializer.toJson<int>(statusCode),
      'statusMessage': serializer.toJson<String>(statusMessage),
      'durationMs': serializer.toJson<int>(durationMs),
      'contentLengthBytes': serializer.toJson<int>(contentLengthBytes),
      'headersJson': serializer.toJson<String>(headersJson),
      'responseHeadersJson': serializer.toJson<String>(responseHeadersJson),
      'bodyContent': serializer.toJson<String?>(bodyContent),
      'executedAt': serializer.toJson<DateTime>(executedAt),
    };
  }

  RequestHistoryEntry copyWith({
    String? id,
    String? method,
    String? url,
    int? statusCode,
    String? statusMessage,
    int? durationMs,
    int? contentLengthBytes,
    String? headersJson,
    String? responseHeadersJson,
    Value<String?> bodyContent = const Value.absent(),
    DateTime? executedAt,
  }) => RequestHistoryEntry(
    id: id ?? this.id,
    method: method ?? this.method,
    url: url ?? this.url,
    statusCode: statusCode ?? this.statusCode,
    statusMessage: statusMessage ?? this.statusMessage,
    durationMs: durationMs ?? this.durationMs,
    contentLengthBytes: contentLengthBytes ?? this.contentLengthBytes,
    headersJson: headersJson ?? this.headersJson,
    responseHeadersJson: responseHeadersJson ?? this.responseHeadersJson,
    bodyContent: bodyContent.present ? bodyContent.value : this.bodyContent,
    executedAt: executedAt ?? this.executedAt,
  );
  RequestHistoryEntry copyWithCompanion(RequestHistoryEntriesCompanion data) {
    return RequestHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      method: data.method.present ? data.method.value : this.method,
      url: data.url.present ? data.url.value : this.url,
      statusCode: data.statusCode.present
          ? data.statusCode.value
          : this.statusCode,
      statusMessage: data.statusMessage.present
          ? data.statusMessage.value
          : this.statusMessage,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      contentLengthBytes: data.contentLengthBytes.present
          ? data.contentLengthBytes.value
          : this.contentLengthBytes,
      headersJson: data.headersJson.present
          ? data.headersJson.value
          : this.headersJson,
      responseHeadersJson: data.responseHeadersJson.present
          ? data.responseHeadersJson.value
          : this.responseHeadersJson,
      bodyContent: data.bodyContent.present
          ? data.bodyContent.value
          : this.bodyContent,
      executedAt: data.executedAt.present
          ? data.executedAt.value
          : this.executedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RequestHistoryEntry(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('statusCode: $statusCode, ')
          ..write('statusMessage: $statusMessage, ')
          ..write('durationMs: $durationMs, ')
          ..write('contentLengthBytes: $contentLengthBytes, ')
          ..write('headersJson: $headersJson, ')
          ..write('responseHeadersJson: $responseHeadersJson, ')
          ..write('bodyContent: $bodyContent, ')
          ..write('executedAt: $executedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    method,
    url,
    statusCode,
    statusMessage,
    durationMs,
    contentLengthBytes,
    headersJson,
    responseHeadersJson,
    bodyContent,
    executedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestHistoryEntry &&
          other.id == this.id &&
          other.method == this.method &&
          other.url == this.url &&
          other.statusCode == this.statusCode &&
          other.statusMessage == this.statusMessage &&
          other.durationMs == this.durationMs &&
          other.contentLengthBytes == this.contentLengthBytes &&
          other.headersJson == this.headersJson &&
          other.responseHeadersJson == this.responseHeadersJson &&
          other.bodyContent == this.bodyContent &&
          other.executedAt == this.executedAt);
}

class RequestHistoryEntriesCompanion
    extends UpdateCompanion<RequestHistoryEntry> {
  final Value<String> id;
  final Value<String> method;
  final Value<String> url;
  final Value<int> statusCode;
  final Value<String> statusMessage;
  final Value<int> durationMs;
  final Value<int> contentLengthBytes;
  final Value<String> headersJson;
  final Value<String> responseHeadersJson;
  final Value<String?> bodyContent;
  final Value<DateTime> executedAt;
  final Value<int> rowid;
  const RequestHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.method = const Value.absent(),
    this.url = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.statusMessage = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.contentLengthBytes = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.responseHeadersJson = const Value.absent(),
    this.bodyContent = const Value.absent(),
    this.executedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestHistoryEntriesCompanion.insert({
    required String id,
    required String method,
    required String url,
    required int statusCode,
    this.statusMessage = const Value.absent(),
    required int durationMs,
    this.contentLengthBytes = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.responseHeadersJson = const Value.absent(),
    this.bodyContent = const Value.absent(),
    this.executedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       method = Value(method),
       url = Value(url),
       statusCode = Value(statusCode),
       durationMs = Value(durationMs);
  static Insertable<RequestHistoryEntry> custom({
    Expression<String>? id,
    Expression<String>? method,
    Expression<String>? url,
    Expression<int>? statusCode,
    Expression<String>? statusMessage,
    Expression<int>? durationMs,
    Expression<int>? contentLengthBytes,
    Expression<String>? headersJson,
    Expression<String>? responseHeadersJson,
    Expression<String>? bodyContent,
    Expression<DateTime>? executedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (method != null) 'method': method,
      if (url != null) 'url': url,
      if (statusCode != null) 'status_code': statusCode,
      if (statusMessage != null) 'status_message': statusMessage,
      if (durationMs != null) 'duration_ms': durationMs,
      if (contentLengthBytes != null)
        'content_length_bytes': contentLengthBytes,
      if (headersJson != null) 'headers_json': headersJson,
      if (responseHeadersJson != null)
        'response_headers_json': responseHeadersJson,
      if (bodyContent != null) 'body_content': bodyContent,
      if (executedAt != null) 'executed_at': executedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestHistoryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? method,
    Value<String>? url,
    Value<int>? statusCode,
    Value<String>? statusMessage,
    Value<int>? durationMs,
    Value<int>? contentLengthBytes,
    Value<String>? headersJson,
    Value<String>? responseHeadersJson,
    Value<String?>? bodyContent,
    Value<DateTime>? executedAt,
    Value<int>? rowid,
  }) {
    return RequestHistoryEntriesCompanion(
      id: id ?? this.id,
      method: method ?? this.method,
      url: url ?? this.url,
      statusCode: statusCode ?? this.statusCode,
      statusMessage: statusMessage ?? this.statusMessage,
      durationMs: durationMs ?? this.durationMs,
      contentLengthBytes: contentLengthBytes ?? this.contentLengthBytes,
      headersJson: headersJson ?? this.headersJson,
      responseHeadersJson: responseHeadersJson ?? this.responseHeadersJson,
      bodyContent: bodyContent ?? this.bodyContent,
      executedAt: executedAt ?? this.executedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (statusCode.present) {
      map['status_code'] = Variable<int>(statusCode.value);
    }
    if (statusMessage.present) {
      map['status_message'] = Variable<String>(statusMessage.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (contentLengthBytes.present) {
      map['content_length_bytes'] = Variable<int>(contentLengthBytes.value);
    }
    if (headersJson.present) {
      map['headers_json'] = Variable<String>(headersJson.value);
    }
    if (responseHeadersJson.present) {
      map['response_headers_json'] = Variable<String>(
        responseHeadersJson.value,
      );
    }
    if (bodyContent.present) {
      map['body_content'] = Variable<String>(bodyContent.value);
    }
    if (executedAt.present) {
      map['executed_at'] = Variable<DateTime>(executedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestHistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('statusCode: $statusCode, ')
          ..write('statusMessage: $statusMessage, ')
          ..write('durationMs: $durationMs, ')
          ..write('contentLengthBytes: $contentLengthBytes, ')
          ..write('headersJson: $headersJson, ')
          ..write('responseHeadersJson: $responseHeadersJson, ')
          ..write('bodyContent: $bodyContent, ')
          ..write('executedAt: $executedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $SavedRequestsTable savedRequests = $SavedRequestsTable(this);
  late final $EnvironmentsTable environments = $EnvironmentsTable(this);
  late final $EnvironmentVariablesTable environmentVariables =
      $EnvironmentVariablesTable(this);
  late final $RequestHistoryEntriesTable requestHistoryEntries =
      $RequestHistoryEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workspaces,
    collections,
    folders,
    savedRequests,
    environments,
    environmentVariables,
    requestHistoryEntries,
  ];
}

typedef $$WorkspacesTableCreateCompanionBuilder =
    WorkspacesCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$WorkspacesTableUpdateCompanionBuilder =
    WorkspacesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspacesTable,
          Workspace,
          $$WorkspacesTableFilterComposer,
          $$WorkspacesTableOrderingComposer,
          $$WorkspacesTableAnnotationComposer,
          $$WorkspacesTableCreateCompanionBuilder,
          $$WorkspacesTableUpdateCompanionBuilder,
          (
            Workspace,
            BaseReferences<_$AppDatabase, $WorkspacesTable, Workspace>,
          ),
          Workspace,
          PrefetchHooks Function()
        > {
  $$WorkspacesTableTableManager(_$AppDatabase db, $WorkspacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspacesTable,
      Workspace,
      $$WorkspacesTableFilterComposer,
      $$WorkspacesTableOrderingComposer,
      $$WorkspacesTableAnnotationComposer,
      $$WorkspacesTableCreateCompanionBuilder,
      $$WorkspacesTableUpdateCompanionBuilder,
      (Workspace, BaseReferences<_$AppDatabase, $WorkspacesTable, Workspace>),
      Workspace,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String id,
      required String workspaceId,
      required String name,
      Value<String?> description,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String> name,
      Value<String?> description,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            Collection,
            BaseReferences<_$AppDatabase, $CollectionsTable, Collection>,
          ),
          Collection,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                workspaceId: workspaceId,
                name: name,
                description: description,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                name: name,
                description: description,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        Collection,
        BaseReferences<_$AppDatabase, $CollectionsTable, Collection>,
      ),
      Collection,
      PrefetchHooks Function()
    >;
typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      required String id,
      required String collectionId,
      Value<String?> parentFolderId,
      required String name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<String> id,
      Value<String> collectionId,
      Value<String?> parentFolderId,
      Value<String> name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
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

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
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

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
          Folder,
          PrefetchHooks Function()
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String?> parentFolderId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                collectionId: collectionId,
                parentFolderId: parentFolderId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String collectionId,
                Value<String?> parentFolderId = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                collectionId: collectionId,
                parentFolderId: parentFolderId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
      Folder,
      PrefetchHooks Function()
    >;
typedef $$SavedRequestsTableCreateCompanionBuilder =
    SavedRequestsCompanion Function({
      required String id,
      required String collectionId,
      Value<String?> folderId,
      required String name,
      Value<String?> description,
      required String method,
      required String url,
      Value<String> queryParamsJson,
      Value<String> headersJson,
      Value<String> bodyType,
      Value<String> bodyContent,
      Value<String> formDataJson,
      Value<String> authType,
      Value<String?> authConfigJson,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SavedRequestsTableUpdateCompanionBuilder =
    SavedRequestsCompanion Function({
      Value<String> id,
      Value<String> collectionId,
      Value<String?> folderId,
      Value<String> name,
      Value<String?> description,
      Value<String> method,
      Value<String> url,
      Value<String> queryParamsJson,
      Value<String> headersJson,
      Value<String> bodyType,
      Value<String> bodyContent,
      Value<String> formDataJson,
      Value<String> authType,
      Value<String?> authConfigJson,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SavedRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedRequestsTable> {
  $$SavedRequestsTableFilterComposer({
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

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get queryParamsJson => $composableBuilder(
    column: $table.queryParamsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyType => $composableBuilder(
    column: $table.bodyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyContent => $composableBuilder(
    column: $table.bodyContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formDataJson => $composableBuilder(
    column: $table.formDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authConfigJson => $composableBuilder(
    column: $table.authConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedRequestsTable> {
  $$SavedRequestsTableOrderingComposer({
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

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get queryParamsJson => $composableBuilder(
    column: $table.queryParamsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyType => $composableBuilder(
    column: $table.bodyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyContent => $composableBuilder(
    column: $table.bodyContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formDataJson => $composableBuilder(
    column: $table.formDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authConfigJson => $composableBuilder(
    column: $table.authConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedRequestsTable> {
  $$SavedRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get queryParamsJson => $composableBuilder(
    column: $table.queryParamsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyType =>
      $composableBuilder(column: $table.bodyType, builder: (column) => column);

  GeneratedColumn<String> get bodyContent => $composableBuilder(
    column: $table.bodyContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get formDataJson => $composableBuilder(
    column: $table.formDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authType =>
      $composableBuilder(column: $table.authType, builder: (column) => column);

  GeneratedColumn<String> get authConfigJson => $composableBuilder(
    column: $table.authConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SavedRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedRequestsTable,
          SavedRequest,
          $$SavedRequestsTableFilterComposer,
          $$SavedRequestsTableOrderingComposer,
          $$SavedRequestsTableAnnotationComposer,
          $$SavedRequestsTableCreateCompanionBuilder,
          $$SavedRequestsTableUpdateCompanionBuilder,
          (
            SavedRequest,
            BaseReferences<_$AppDatabase, $SavedRequestsTable, SavedRequest>,
          ),
          SavedRequest,
          PrefetchHooks Function()
        > {
  $$SavedRequestsTableTableManager(_$AppDatabase db, $SavedRequestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> queryParamsJson = const Value.absent(),
                Value<String> headersJson = const Value.absent(),
                Value<String> bodyType = const Value.absent(),
                Value<String> bodyContent = const Value.absent(),
                Value<String> formDataJson = const Value.absent(),
                Value<String> authType = const Value.absent(),
                Value<String?> authConfigJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedRequestsCompanion(
                id: id,
                collectionId: collectionId,
                folderId: folderId,
                name: name,
                description: description,
                method: method,
                url: url,
                queryParamsJson: queryParamsJson,
                headersJson: headersJson,
                bodyType: bodyType,
                bodyContent: bodyContent,
                formDataJson: formDataJson,
                authType: authType,
                authConfigJson: authConfigJson,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String collectionId,
                Value<String?> folderId = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                required String method,
                required String url,
                Value<String> queryParamsJson = const Value.absent(),
                Value<String> headersJson = const Value.absent(),
                Value<String> bodyType = const Value.absent(),
                Value<String> bodyContent = const Value.absent(),
                Value<String> formDataJson = const Value.absent(),
                Value<String> authType = const Value.absent(),
                Value<String?> authConfigJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedRequestsCompanion.insert(
                id: id,
                collectionId: collectionId,
                folderId: folderId,
                name: name,
                description: description,
                method: method,
                url: url,
                queryParamsJson: queryParamsJson,
                headersJson: headersJson,
                bodyType: bodyType,
                bodyContent: bodyContent,
                formDataJson: formDataJson,
                authType: authType,
                authConfigJson: authConfigJson,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedRequestsTable,
      SavedRequest,
      $$SavedRequestsTableFilterComposer,
      $$SavedRequestsTableOrderingComposer,
      $$SavedRequestsTableAnnotationComposer,
      $$SavedRequestsTableCreateCompanionBuilder,
      $$SavedRequestsTableUpdateCompanionBuilder,
      (
        SavedRequest,
        BaseReferences<_$AppDatabase, $SavedRequestsTable, SavedRequest>,
      ),
      SavedRequest,
      PrefetchHooks Function()
    >;
typedef $$EnvironmentsTableCreateCompanionBuilder =
    EnvironmentsCompanion Function({
      required String id,
      required String workspaceId,
      required String name,
      Value<String> colorHex,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$EnvironmentsTableUpdateCompanionBuilder =
    EnvironmentsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String> name,
      Value<String> colorHex,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$EnvironmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnvironmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnvironmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvironmentsTable> {
  $$EnvironmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EnvironmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvironmentsTable,
          Environment,
          $$EnvironmentsTableFilterComposer,
          $$EnvironmentsTableOrderingComposer,
          $$EnvironmentsTableAnnotationComposer,
          $$EnvironmentsTableCreateCompanionBuilder,
          $$EnvironmentsTableUpdateCompanionBuilder,
          (
            Environment,
            BaseReferences<_$AppDatabase, $EnvironmentsTable, Environment>,
          ),
          Environment,
          PrefetchHooks Function()
        > {
  $$EnvironmentsTableTableManager(_$AppDatabase db, $EnvironmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvironmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvironmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvironmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentsCompanion(
                id: id,
                workspaceId: workspaceId,
                name: name,
                colorHex: colorHex,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String name,
                Value<String> colorHex = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                name: name,
                colorHex: colorHex,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnvironmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvironmentsTable,
      Environment,
      $$EnvironmentsTableFilterComposer,
      $$EnvironmentsTableOrderingComposer,
      $$EnvironmentsTableAnnotationComposer,
      $$EnvironmentsTableCreateCompanionBuilder,
      $$EnvironmentsTableUpdateCompanionBuilder,
      (
        Environment,
        BaseReferences<_$AppDatabase, $EnvironmentsTable, Environment>,
      ),
      Environment,
      PrefetchHooks Function()
    >;
typedef $$EnvironmentVariablesTableCreateCompanionBuilder =
    EnvironmentVariablesCompanion Function({
      required String id,
      required String environmentId,
      required String key,
      Value<String> value,
      Value<bool> isSecret,
      Value<String?> secretRefId,
      Value<bool> isEnabled,
      Value<int> rowid,
    });
typedef $$EnvironmentVariablesTableUpdateCompanionBuilder =
    EnvironmentVariablesCompanion Function({
      Value<String> id,
      Value<String> environmentId,
      Value<String> key,
      Value<String> value,
      Value<bool> isSecret,
      Value<String?> secretRefId,
      Value<bool> isEnabled,
      Value<int> rowid,
    });

class $$EnvironmentVariablesTableFilterComposer
    extends Composer<_$AppDatabase, $EnvironmentVariablesTable> {
  $$EnvironmentVariablesTableFilterComposer({
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

  ColumnFilters<String> get environmentId => $composableBuilder(
    column: $table.environmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSecret => $composableBuilder(
    column: $table.isSecret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secretRefId => $composableBuilder(
    column: $table.secretRefId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnvironmentVariablesTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvironmentVariablesTable> {
  $$EnvironmentVariablesTableOrderingComposer({
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

  ColumnOrderings<String> get environmentId => $composableBuilder(
    column: $table.environmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSecret => $composableBuilder(
    column: $table.isSecret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secretRefId => $composableBuilder(
    column: $table.secretRefId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnvironmentVariablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvironmentVariablesTable> {
  $$EnvironmentVariablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get environmentId => $composableBuilder(
    column: $table.environmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<bool> get isSecret =>
      $composableBuilder(column: $table.isSecret, builder: (column) => column);

  GeneratedColumn<String> get secretRefId => $composableBuilder(
    column: $table.secretRefId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);
}

class $$EnvironmentVariablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvironmentVariablesTable,
          EnvironmentVariable,
          $$EnvironmentVariablesTableFilterComposer,
          $$EnvironmentVariablesTableOrderingComposer,
          $$EnvironmentVariablesTableAnnotationComposer,
          $$EnvironmentVariablesTableCreateCompanionBuilder,
          $$EnvironmentVariablesTableUpdateCompanionBuilder,
          (
            EnvironmentVariable,
            BaseReferences<
              _$AppDatabase,
              $EnvironmentVariablesTable,
              EnvironmentVariable
            >,
          ),
          EnvironmentVariable,
          PrefetchHooks Function()
        > {
  $$EnvironmentVariablesTableTableManager(
    _$AppDatabase db,
    $EnvironmentVariablesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvironmentVariablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvironmentVariablesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EnvironmentVariablesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> environmentId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<bool> isSecret = const Value.absent(),
                Value<String?> secretRefId = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentVariablesCompanion(
                id: id,
                environmentId: environmentId,
                key: key,
                value: value,
                isSecret: isSecret,
                secretRefId: secretRefId,
                isEnabled: isEnabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String environmentId,
                required String key,
                Value<String> value = const Value.absent(),
                Value<bool> isSecret = const Value.absent(),
                Value<String?> secretRefId = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentVariablesCompanion.insert(
                id: id,
                environmentId: environmentId,
                key: key,
                value: value,
                isSecret: isSecret,
                secretRefId: secretRefId,
                isEnabled: isEnabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnvironmentVariablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvironmentVariablesTable,
      EnvironmentVariable,
      $$EnvironmentVariablesTableFilterComposer,
      $$EnvironmentVariablesTableOrderingComposer,
      $$EnvironmentVariablesTableAnnotationComposer,
      $$EnvironmentVariablesTableCreateCompanionBuilder,
      $$EnvironmentVariablesTableUpdateCompanionBuilder,
      (
        EnvironmentVariable,
        BaseReferences<
          _$AppDatabase,
          $EnvironmentVariablesTable,
          EnvironmentVariable
        >,
      ),
      EnvironmentVariable,
      PrefetchHooks Function()
    >;
typedef $$RequestHistoryEntriesTableCreateCompanionBuilder =
    RequestHistoryEntriesCompanion Function({
      required String id,
      required String method,
      required String url,
      required int statusCode,
      Value<String> statusMessage,
      required int durationMs,
      Value<int> contentLengthBytes,
      Value<String> headersJson,
      Value<String> responseHeadersJson,
      Value<String?> bodyContent,
      Value<DateTime> executedAt,
      Value<int> rowid,
    });
typedef $$RequestHistoryEntriesTableUpdateCompanionBuilder =
    RequestHistoryEntriesCompanion Function({
      Value<String> id,
      Value<String> method,
      Value<String> url,
      Value<int> statusCode,
      Value<String> statusMessage,
      Value<int> durationMs,
      Value<int> contentLengthBytes,
      Value<String> headersJson,
      Value<String> responseHeadersJson,
      Value<String?> bodyContent,
      Value<DateTime> executedAt,
      Value<int> rowid,
    });

class $$RequestHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $RequestHistoryEntriesTable> {
  $$RequestHistoryEntriesTableFilterComposer({
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

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusMessage => $composableBuilder(
    column: $table.statusMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentLengthBytes => $composableBuilder(
    column: $table.contentLengthBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseHeadersJson => $composableBuilder(
    column: $table.responseHeadersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyContent => $composableBuilder(
    column: $table.bodyContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RequestHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RequestHistoryEntriesTable> {
  $$RequestHistoryEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusMessage => $composableBuilder(
    column: $table.statusMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentLengthBytes => $composableBuilder(
    column: $table.contentLengthBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseHeadersJson => $composableBuilder(
    column: $table.responseHeadersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyContent => $composableBuilder(
    column: $table.bodyContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RequestHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RequestHistoryEntriesTable> {
  $$RequestHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusMessage => $composableBuilder(
    column: $table.statusMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contentLengthBytes => $composableBuilder(
    column: $table.contentLengthBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseHeadersJson => $composableBuilder(
    column: $table.responseHeadersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyContent => $composableBuilder(
    column: $table.bodyContent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => column,
  );
}

class $$RequestHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RequestHistoryEntriesTable,
          RequestHistoryEntry,
          $$RequestHistoryEntriesTableFilterComposer,
          $$RequestHistoryEntriesTableOrderingComposer,
          $$RequestHistoryEntriesTableAnnotationComposer,
          $$RequestHistoryEntriesTableCreateCompanionBuilder,
          $$RequestHistoryEntriesTableUpdateCompanionBuilder,
          (
            RequestHistoryEntry,
            BaseReferences<
              _$AppDatabase,
              $RequestHistoryEntriesTable,
              RequestHistoryEntry
            >,
          ),
          RequestHistoryEntry,
          PrefetchHooks Function()
        > {
  $$RequestHistoryEntriesTableTableManager(
    _$AppDatabase db,
    $RequestHistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RequestHistoryEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RequestHistoryEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RequestHistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int> statusCode = const Value.absent(),
                Value<String> statusMessage = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> contentLengthBytes = const Value.absent(),
                Value<String> headersJson = const Value.absent(),
                Value<String> responseHeadersJson = const Value.absent(),
                Value<String?> bodyContent = const Value.absent(),
                Value<DateTime> executedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestHistoryEntriesCompanion(
                id: id,
                method: method,
                url: url,
                statusCode: statusCode,
                statusMessage: statusMessage,
                durationMs: durationMs,
                contentLengthBytes: contentLengthBytes,
                headersJson: headersJson,
                responseHeadersJson: responseHeadersJson,
                bodyContent: bodyContent,
                executedAt: executedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String method,
                required String url,
                required int statusCode,
                Value<String> statusMessage = const Value.absent(),
                required int durationMs,
                Value<int> contentLengthBytes = const Value.absent(),
                Value<String> headersJson = const Value.absent(),
                Value<String> responseHeadersJson = const Value.absent(),
                Value<String?> bodyContent = const Value.absent(),
                Value<DateTime> executedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestHistoryEntriesCompanion.insert(
                id: id,
                method: method,
                url: url,
                statusCode: statusCode,
                statusMessage: statusMessage,
                durationMs: durationMs,
                contentLengthBytes: contentLengthBytes,
                headersJson: headersJson,
                responseHeadersJson: responseHeadersJson,
                bodyContent: bodyContent,
                executedAt: executedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RequestHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RequestHistoryEntriesTable,
      RequestHistoryEntry,
      $$RequestHistoryEntriesTableFilterComposer,
      $$RequestHistoryEntriesTableOrderingComposer,
      $$RequestHistoryEntriesTableAnnotationComposer,
      $$RequestHistoryEntriesTableCreateCompanionBuilder,
      $$RequestHistoryEntriesTableUpdateCompanionBuilder,
      (
        RequestHistoryEntry,
        BaseReferences<
          _$AppDatabase,
          $RequestHistoryEntriesTable,
          RequestHistoryEntry
        >,
      ),
      RequestHistoryEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db, _db.workspaces);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$SavedRequestsTableTableManager get savedRequests =>
      $$SavedRequestsTableTableManager(_db, _db.savedRequests);
  $$EnvironmentsTableTableManager get environments =>
      $$EnvironmentsTableTableManager(_db, _db.environments);
  $$EnvironmentVariablesTableTableManager get environmentVariables =>
      $$EnvironmentVariablesTableTableManager(_db, _db.environmentVariables);
  $$RequestHistoryEntriesTableTableManager get requestHistoryEntries =>
      $$RequestHistoryEntriesTableTableManager(_db, _db.requestHistoryEntries);
}
