// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bloodTypeMeta = const VerificationMeta(
    'bloodType',
  );
  @override
  late final GeneratedColumn<String> bloodType = GeneratedColumn<String>(
    'blood_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allergiesMeta = const VerificationMeta(
    'allergies',
  );
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
    'allergies',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emergencyContactNameMeta =
      const VerificationMeta('emergencyContactName');
  @override
  late final GeneratedColumn<String> emergencyContactName =
      GeneratedColumn<String>(
        'emergency_contact_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _emergencyContactPhoneMeta =
      const VerificationMeta('emergencyContactPhone');
  @override
  late final GeneratedColumn<String> emergencyContactPhone =
      GeneratedColumn<String>(
        'emergency_contact_phone',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firstName,
    lastName,
    birthDate,
    gender,
    heightCm,
    weightKg,
    bloodType,
    allergies,
    emergencyContactName,
    emergencyContactPhone,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('blood_type')) {
      context.handle(
        _bloodTypeMeta,
        bloodType.isAcceptableOrUnknown(data['blood_type']!, _bloodTypeMeta),
      );
    }
    if (data.containsKey('allergies')) {
      context.handle(
        _allergiesMeta,
        allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta),
      );
    }
    if (data.containsKey('emergency_contact_name')) {
      context.handle(
        _emergencyContactNameMeta,
        emergencyContactName.isAcceptableOrUnknown(
          data['emergency_contact_name']!,
          _emergencyContactNameMeta,
        ),
      );
    }
    if (data.containsKey('emergency_contact_phone')) {
      context.handle(
        _emergencyContactPhoneMeta,
        emergencyContactPhone.isAcceptableOrUnknown(
          data['emergency_contact_phone']!,
          _emergencyContactPhoneMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      bloodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blood_type'],
      ),
      allergies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergies'],
      ),
      emergencyContactName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emergency_contact_name'],
      ),
      emergencyContactPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emergency_contact_phone'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
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
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? bloodType;
  final String? allergies;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.bloodType,
    this.allergies,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || bloodType != null) {
      map['blood_type'] = Variable<String>(bloodType);
    }
    if (!nullToAbsent || allergies != null) {
      map['allergies'] = Variable<String>(allergies);
    }
    if (!nullToAbsent || emergencyContactName != null) {
      map['emergency_contact_name'] = Variable<String>(emergencyContactName);
    }
    if (!nullToAbsent || emergencyContactPhone != null) {
      map['emergency_contact_phone'] = Variable<String>(emergencyContactPhone);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      bloodType: bloodType == null && nullToAbsent
          ? const Value.absent()
          : Value(bloodType),
      allergies: allergies == null && nullToAbsent
          ? const Value.absent()
          : Value(allergies),
      emergencyContactName: emergencyContactName == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyContactName),
      emergencyContactPhone: emergencyContactPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyContactPhone),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      gender: serializer.fromJson<String?>(json['gender']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      bloodType: serializer.fromJson<String?>(json['bloodType']),
      allergies: serializer.fromJson<String?>(json['allergies']),
      emergencyContactName: serializer.fromJson<String?>(
        json['emergencyContactName'],
      ),
      emergencyContactPhone: serializer.fromJson<String?>(
        json['emergencyContactPhone'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'gender': serializer.toJson<String?>(gender),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'bloodType': serializer.toJson<String?>(bloodType),
      'allergies': serializer.toJson<String?>(allergies),
      'emergencyContactName': serializer.toJson<String?>(emergencyContactName),
      'emergencyContactPhone': serializer.toJson<String?>(
        emergencyContactPhone,
      ),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Profile copyWith({
    int? id,
    String? firstName,
    String? lastName,
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<String?> bloodType = const Value.absent(),
    Value<String?> allergies = const Value.absent(),
    Value<String?> emergencyContactName = const Value.absent(),
    Value<String?> emergencyContactPhone = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Profile(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    gender: gender.present ? gender.value : this.gender,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    bloodType: bloodType.present ? bloodType.value : this.bloodType,
    allergies: allergies.present ? allergies.value : this.allergies,
    emergencyContactName: emergencyContactName.present
        ? emergencyContactName.value
        : this.emergencyContactName,
    emergencyContactPhone: emergencyContactPhone.present
        ? emergencyContactPhone.value
        : this.emergencyContactPhone,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      gender: data.gender.present ? data.gender.value : this.gender,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      bloodType: data.bloodType.present ? data.bloodType.value : this.bloodType,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      emergencyContactName: data.emergencyContactName.present
          ? data.emergencyContactName.value
          : this.emergencyContactName,
      emergencyContactPhone: data.emergencyContactPhone.present
          ? data.emergencyContactPhone.value
          : this.emergencyContactPhone,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('bloodType: $bloodType, ')
          ..write('allergies: $allergies, ')
          ..write('emergencyContactName: $emergencyContactName, ')
          ..write('emergencyContactPhone: $emergencyContactPhone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firstName,
    lastName,
    birthDate,
    gender,
    heightCm,
    weightKg,
    bloodType,
    allergies,
    emergencyContactName,
    emergencyContactPhone,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.birthDate == this.birthDate &&
          other.gender == this.gender &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.bloodType == this.bloodType &&
          other.allergies == this.allergies &&
          other.emergencyContactName == this.emergencyContactName &&
          other.emergencyContactPhone == this.emergencyContactPhone &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<DateTime?> birthDate;
  final Value<String?> gender;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<String?> bloodType;
  final Value<String?> allergies;
  final Value<String?> emergencyContactName;
  final Value<String?> emergencyContactPhone;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.bloodType = const Value.absent(),
    this.allergies = const Value.absent(),
    this.emergencyContactName = const Value.absent(),
    this.emergencyContactPhone = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String firstName,
    required String lastName,
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.bloodType = const Value.absent(),
    this.allergies = const Value.absent(),
    this.emergencyContactName = const Value.absent(),
    this.emergencyContactPhone = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : firstName = Value(firstName),
       lastName = Value(lastName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<DateTime>? birthDate,
    Expression<String>? gender,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<String>? bloodType,
    Expression<String>? allergies,
    Expression<String>? emergencyContactName,
    Expression<String>? emergencyContactPhone,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (birthDate != null) 'birth_date': birthDate,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (bloodType != null) 'blood_type': bloodType,
      if (allergies != null) 'allergies': allergies,
      if (emergencyContactName != null)
        'emergency_contact_name': emergencyContactName,
      if (emergencyContactPhone != null)
        'emergency_contact_phone': emergencyContactPhone,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<DateTime?>? birthDate,
    Value<String?>? gender,
    Value<double?>? heightCm,
    Value<double?>? weightKg,
    Value<String?>? bloodType,
    Value<String?>? allergies,
    Value<String?>? emergencyContactName,
    Value<String?>? emergencyContactPhone,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (bloodType.present) {
      map['blood_type'] = Variable<String>(bloodType.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    if (emergencyContactName.present) {
      map['emergency_contact_name'] = Variable<String>(
        emergencyContactName.value,
      );
    }
    if (emergencyContactPhone.present) {
      map['emergency_contact_phone'] = Variable<String>(
        emergencyContactPhone.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('bloodType: $bloodType, ')
          ..write('allergies: $allergies, ')
          ..write('emergencyContactName: $emergencyContactName, ')
          ..write('emergencyContactPhone: $emergencyContactPhone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
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
  static const VerificationMeta _doseAmountMeta = const VerificationMeta(
    'doseAmount',
  );
  @override
  late final GeneratedColumn<String> doseAmount = GeneratedColumn<String>(
    'dose_amount',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doseUnitMeta = const VerificationMeta(
    'doseUnit',
  );
  @override
  late final GeneratedColumn<String> doseUnit = GeneratedColumn<String>(
    'dose_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    description,
    doseAmount,
    doseUnit,
    active,
    startDate,
    endDate,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
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
    if (data.containsKey('dose_amount')) {
      context.handle(
        _doseAmountMeta,
        doseAmount.isAcceptableOrUnknown(data['dose_amount']!, _doseAmountMeta),
      );
    }
    if (data.containsKey('dose_unit')) {
      context.handle(
        _doseUnitMeta,
        doseUnit.isAcceptableOrUnknown(data['dose_unit']!, _doseUnitMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      doseAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_amount'],
      ),
      doseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_unit'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
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
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final int id;
  final int profileId;
  final String name;
  final String? description;
  final String? doseAmount;
  final String? doseUnit;
  final bool active;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Medication({
    required this.id,
    required this.profileId,
    required this.name,
    this.description,
    this.doseAmount,
    this.doseUnit,
    required this.active,
    this.startDate,
    this.endDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || doseAmount != null) {
      map['dose_amount'] = Variable<String>(doseAmount);
    }
    if (!nullToAbsent || doseUnit != null) {
      map['dose_unit'] = Variable<String>(doseUnit);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      doseAmount: doseAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(doseAmount),
      doseUnit: doseUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(doseUnit),
      active: Value(active),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      doseAmount: serializer.fromJson<String?>(json['doseAmount']),
      doseUnit: serializer.fromJson<String?>(json['doseUnit']),
      active: serializer.fromJson<bool>(json['active']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'doseAmount': serializer.toJson<String?>(doseAmount),
      'doseUnit': serializer.toJson<String?>(doseUnit),
      'active': serializer.toJson<bool>(active),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Medication copyWith({
    int? id,
    int? profileId,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> doseAmount = const Value.absent(),
    Value<String?> doseUnit = const Value.absent(),
    bool? active,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Medication(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    doseAmount: doseAmount.present ? doseAmount.value : this.doseAmount,
    doseUnit: doseUnit.present ? doseUnit.value : this.doseUnit,
    active: active ?? this.active,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      doseAmount: data.doseAmount.present
          ? data.doseAmount.value
          : this.doseAmount,
      doseUnit: data.doseUnit.present ? data.doseUnit.value : this.doseUnit,
      active: data.active.present ? data.active.value : this.active,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('doseAmount: $doseAmount, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('active: $active, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    description,
    doseAmount,
    doseUnit,
    active,
    startDate,
    endDate,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.description == this.description &&
          other.doseAmount == this.doseAmount &&
          other.doseUnit == this.doseUnit &&
          other.active == this.active &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> doseAmount;
  final Value<String?> doseUnit;
  final Value<bool> active;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.doseAmount = const Value.absent(),
    this.doseUnit = const Value.absent(),
    this.active = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String name,
    this.description = const Value.absent(),
    this.doseAmount = const Value.absent(),
    this.doseUnit = const Value.absent(),
    this.active = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : profileId = Value(profileId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? doseAmount,
    Expression<String>? doseUnit,
    Expression<bool>? active,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (doseAmount != null) 'dose_amount': doseAmount,
      if (doseUnit != null) 'dose_unit': doseUnit,
      if (active != null) 'active': active,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MedicationsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? doseAmount,
    Value<String?>? doseUnit,
    Value<bool>? active,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      description: description ?? this.description,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      active: active ?? this.active,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (doseAmount.present) {
      map['dose_amount'] = Variable<String>(doseAmount.value);
    }
    if (doseUnit.present) {
      map['dose_unit'] = Variable<String>(doseUnit.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('doseAmount: $doseAmount, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('active: $active, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MedicationSchedulesTable extends MedicationSchedules
    with TableInfo<$MedicationSchedulesTable, MedicationSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
  );
  static const VerificationMeta _scheduleTypeMeta = const VerificationMeta(
    'scheduleType',
  );
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleConfigMeta = const VerificationMeta(
    'scheduleConfig',
  );
  @override
  late final GeneratedColumn<String> scheduleConfig = GeneratedColumn<String>(
    'schedule_config',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    scheduleType,
    scheduleConfig,
    startDate,
    endDate,
    instructions,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
        _scheduleTypeMeta,
        scheduleType.isAcceptableOrUnknown(
          data['schedule_type']!,
          _scheduleTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleTypeMeta);
    }
    if (data.containsKey('schedule_config')) {
      context.handle(
        _scheduleConfigMeta,
        scheduleConfig.isAcceptableOrUnknown(
          data['schedule_config']!,
          _scheduleConfigMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleConfigMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      scheduleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_type'],
      )!,
      scheduleConfig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_config'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $MedicationSchedulesTable createAlias(String alias) {
    return $MedicationSchedulesTable(attachedDatabase, alias);
  }
}

class MedicationSchedule extends DataClass
    implements Insertable<MedicationSchedule> {
  final int id;
  final int medicationId;
  final String scheduleType;
  final String scheduleConfig;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? instructions;
  final bool active;
  const MedicationSchedule({
    required this.id,
    required this.medicationId,
    required this.scheduleType,
    required this.scheduleConfig,
    this.startDate,
    this.endDate,
    this.instructions,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    map['schedule_type'] = Variable<String>(scheduleType);
    map['schedule_config'] = Variable<String>(scheduleConfig);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  MedicationSchedulesCompanion toCompanion(bool nullToAbsent) {
    return MedicationSchedulesCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      scheduleType: Value(scheduleType),
      scheduleConfig: Value(scheduleConfig),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
      active: Value(active),
    );
  }

  factory MedicationSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationSchedule(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      scheduleConfig: serializer.fromJson<String>(json['scheduleConfig']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      instructions: serializer.fromJson<String?>(json['instructions']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'scheduleConfig': serializer.toJson<String>(scheduleConfig),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'instructions': serializer.toJson<String?>(instructions),
      'active': serializer.toJson<bool>(active),
    };
  }

  MedicationSchedule copyWith({
    int? id,
    int? medicationId,
    String? scheduleType,
    String? scheduleConfig,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> instructions = const Value.absent(),
    bool? active,
  }) => MedicationSchedule(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    scheduleType: scheduleType ?? this.scheduleType,
    scheduleConfig: scheduleConfig ?? this.scheduleConfig,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    instructions: instructions.present ? instructions.value : this.instructions,
    active: active ?? this.active,
  );
  MedicationSchedule copyWithCompanion(MedicationSchedulesCompanion data) {
    return MedicationSchedule(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      scheduleConfig: data.scheduleConfig.present
          ? data.scheduleConfig.value
          : this.scheduleConfig,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationSchedule(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('scheduleConfig: $scheduleConfig, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('instructions: $instructions, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    scheduleType,
    scheduleConfig,
    startDate,
    endDate,
    instructions,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationSchedule &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.scheduleType == this.scheduleType &&
          other.scheduleConfig == this.scheduleConfig &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.instructions == this.instructions &&
          other.active == this.active);
}

class MedicationSchedulesCompanion extends UpdateCompanion<MedicationSchedule> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<String> scheduleType;
  final Value<String> scheduleConfig;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> instructions;
  final Value<bool> active;
  const MedicationSchedulesCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.scheduleConfig = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.instructions = const Value.absent(),
    this.active = const Value.absent(),
  });
  MedicationSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required String scheduleType,
    required String scheduleConfig,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.instructions = const Value.absent(),
    this.active = const Value.absent(),
  }) : medicationId = Value(medicationId),
       scheduleType = Value(scheduleType),
       scheduleConfig = Value(scheduleConfig);
  static Insertable<MedicationSchedule> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<String>? scheduleType,
    Expression<String>? scheduleConfig,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? instructions,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (scheduleConfig != null) 'schedule_config': scheduleConfig,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (instructions != null) 'instructions': instructions,
      if (active != null) 'active': active,
    });
  }

  MedicationSchedulesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<String>? scheduleType,
    Value<String>? scheduleConfig,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<String?>? instructions,
    Value<bool>? active,
  }) {
    return MedicationSchedulesCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduleConfig: scheduleConfig ?? this.scheduleConfig,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructions: instructions ?? this.instructions,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (scheduleConfig.present) {
      map['schedule_config'] = Variable<String>(scheduleConfig.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('scheduleConfig: $scheduleConfig, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('instructions: $instructions, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $MedicationLogsTable extends MedicationLogs
    with TableInfo<$MedicationLogsTable, MedicationLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicationScheduleIdMeta =
      const VerificationMeta('medicationScheduleId');
  @override
  late final GeneratedColumn<int> medicationScheduleId = GeneratedColumn<int>(
    'medication_schedule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medication_schedules (id)',
    ),
  );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledTime =
      GeneratedColumn<DateTime>(
        'scheduled_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _takenTimeMeta = const VerificationMeta(
    'takenTime',
  );
  @override
  late final GeneratedColumn<DateTime> takenTime = GeneratedColumn<DateTime>(
    'taken_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationScheduleId,
    scheduledTime,
    takenTime,
    status,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_schedule_id')) {
      context.handle(
        _medicationScheduleIdMeta,
        medicationScheduleId.isAcceptableOrUnknown(
          data['medication_schedule_id']!,
          _medicationScheduleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationScheduleIdMeta);
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('taken_time')) {
      context.handle(
        _takenTimeMeta,
        takenTime.isAcceptableOrUnknown(data['taken_time']!, _takenTimeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationScheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_schedule_id'],
      )!,
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_time'],
      )!,
      takenTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_time'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MedicationLogsTable createAlias(String alias) {
    return $MedicationLogsTable(attachedDatabase, alias);
  }
}

class MedicationLog extends DataClass implements Insertable<MedicationLog> {
  final int id;
  final int medicationScheduleId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final String status;
  final String? notes;
  final DateTime createdAt;
  const MedicationLog({
    required this.id,
    required this.medicationScheduleId,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_schedule_id'] = Variable<int>(medicationScheduleId);
    map['scheduled_time'] = Variable<DateTime>(scheduledTime);
    if (!nullToAbsent || takenTime != null) {
      map['taken_time'] = Variable<DateTime>(takenTime);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicationLogsCompanion toCompanion(bool nullToAbsent) {
    return MedicationLogsCompanion(
      id: Value(id),
      medicationScheduleId: Value(medicationScheduleId),
      scheduledTime: Value(scheduledTime),
      takenTime: takenTime == null && nullToAbsent
          ? const Value.absent()
          : Value(takenTime),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory MedicationLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationLog(
      id: serializer.fromJson<int>(json['id']),
      medicationScheduleId: serializer.fromJson<int>(
        json['medicationScheduleId'],
      ),
      scheduledTime: serializer.fromJson<DateTime>(json['scheduledTime']),
      takenTime: serializer.fromJson<DateTime?>(json['takenTime']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationScheduleId': serializer.toJson<int>(medicationScheduleId),
      'scheduledTime': serializer.toJson<DateTime>(scheduledTime),
      'takenTime': serializer.toJson<DateTime?>(takenTime),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicationLog copyWith({
    int? id,
    int? medicationScheduleId,
    DateTime? scheduledTime,
    Value<DateTime?> takenTime = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => MedicationLog(
    id: id ?? this.id,
    medicationScheduleId: medicationScheduleId ?? this.medicationScheduleId,
    scheduledTime: scheduledTime ?? this.scheduledTime,
    takenTime: takenTime.present ? takenTime.value : this.takenTime,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  MedicationLog copyWithCompanion(MedicationLogsCompanion data) {
    return MedicationLog(
      id: data.id.present ? data.id.value : this.id,
      medicationScheduleId: data.medicationScheduleId.present
          ? data.medicationScheduleId.value
          : this.medicationScheduleId,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      takenTime: data.takenTime.present ? data.takenTime.value : this.takenTime,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationLog(')
          ..write('id: $id, ')
          ..write('medicationScheduleId: $medicationScheduleId, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('takenTime: $takenTime, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationScheduleId,
    scheduledTime,
    takenTime,
    status,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationLog &&
          other.id == this.id &&
          other.medicationScheduleId == this.medicationScheduleId &&
          other.scheduledTime == this.scheduledTime &&
          other.takenTime == this.takenTime &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MedicationLogsCompanion extends UpdateCompanion<MedicationLog> {
  final Value<int> id;
  final Value<int> medicationScheduleId;
  final Value<DateTime> scheduledTime;
  final Value<DateTime?> takenTime;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const MedicationLogsCompanion({
    this.id = const Value.absent(),
    this.medicationScheduleId = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.takenTime = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MedicationLogsCompanion.insert({
    this.id = const Value.absent(),
    required int medicationScheduleId,
    required DateTime scheduledTime,
    this.takenTime = const Value.absent(),
    required String status,
    this.notes = const Value.absent(),
    required DateTime createdAt,
  }) : medicationScheduleId = Value(medicationScheduleId),
       scheduledTime = Value(scheduledTime),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<MedicationLog> custom({
    Expression<int>? id,
    Expression<int>? medicationScheduleId,
    Expression<DateTime>? scheduledTime,
    Expression<DateTime>? takenTime,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationScheduleId != null)
        'medication_schedule_id': medicationScheduleId,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (takenTime != null) 'taken_time': takenTime,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MedicationLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationScheduleId,
    Value<DateTime>? scheduledTime,
    Value<DateTime?>? takenTime,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return MedicationLogsCompanion(
      id: id ?? this.id,
      medicationScheduleId: medicationScheduleId ?? this.medicationScheduleId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationScheduleId.present) {
      map['medication_schedule_id'] = Variable<int>(medicationScheduleId.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime.value);
    }
    if (takenTime.present) {
      map['taken_time'] = Variable<DateTime>(takenTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationLogsCompanion(')
          ..write('id: $id, ')
          ..write('medicationScheduleId: $medicationScheduleId, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('takenTime: $takenTime, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MedicationAlternativesTable extends MedicationAlternatives
    with TableInfo<$MedicationAlternativesTable, MedicationAlternative> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationAlternativesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
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
  static const VerificationMeta _doseAmountMeta = const VerificationMeta(
    'doseAmount',
  );
  @override
  late final GeneratedColumn<String> doseAmount = GeneratedColumn<String>(
    'dose_amount',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doseUnitMeta = const VerificationMeta(
    'doseUnit',
  );
  @override
  late final GeneratedColumn<String> doseUnit = GeneratedColumn<String>(
    'dose_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doctorApprovedMeta = const VerificationMeta(
    'doctorApproved',
  );
  @override
  late final GeneratedColumn<bool> doctorApproved = GeneratedColumn<bool>(
    'doctor_approved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("doctor_approved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    name,
    doseAmount,
    doseUnit,
    doctorApproved,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_alternatives';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationAlternative> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dose_amount')) {
      context.handle(
        _doseAmountMeta,
        doseAmount.isAcceptableOrUnknown(data['dose_amount']!, _doseAmountMeta),
      );
    }
    if (data.containsKey('dose_unit')) {
      context.handle(
        _doseUnitMeta,
        doseUnit.isAcceptableOrUnknown(data['dose_unit']!, _doseUnitMeta),
      );
    }
    if (data.containsKey('doctor_approved')) {
      context.handle(
        _doctorApprovedMeta,
        doctorApproved.isAcceptableOrUnknown(
          data['doctor_approved']!,
          _doctorApprovedMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationAlternative map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationAlternative(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      doseAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_amount'],
      ),
      doseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_unit'],
      ),
      doctorApproved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}doctor_approved'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MedicationAlternativesTable createAlias(String alias) {
    return $MedicationAlternativesTable(attachedDatabase, alias);
  }
}

class MedicationAlternative extends DataClass
    implements Insertable<MedicationAlternative> {
  final int id;
  final int medicationId;
  final String name;
  final String? doseAmount;
  final String? doseUnit;
  final bool doctorApproved;
  final String? notes;
  final DateTime createdAt;
  const MedicationAlternative({
    required this.id,
    required this.medicationId,
    required this.name,
    this.doseAmount,
    this.doseUnit,
    required this.doctorApproved,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || doseAmount != null) {
      map['dose_amount'] = Variable<String>(doseAmount);
    }
    if (!nullToAbsent || doseUnit != null) {
      map['dose_unit'] = Variable<String>(doseUnit);
    }
    map['doctor_approved'] = Variable<bool>(doctorApproved);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicationAlternativesCompanion toCompanion(bool nullToAbsent) {
    return MedicationAlternativesCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      name: Value(name),
      doseAmount: doseAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(doseAmount),
      doseUnit: doseUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(doseUnit),
      doctorApproved: Value(doctorApproved),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory MedicationAlternative.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationAlternative(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      name: serializer.fromJson<String>(json['name']),
      doseAmount: serializer.fromJson<String?>(json['doseAmount']),
      doseUnit: serializer.fromJson<String?>(json['doseUnit']),
      doctorApproved: serializer.fromJson<bool>(json['doctorApproved']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'name': serializer.toJson<String>(name),
      'doseAmount': serializer.toJson<String?>(doseAmount),
      'doseUnit': serializer.toJson<String?>(doseUnit),
      'doctorApproved': serializer.toJson<bool>(doctorApproved),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicationAlternative copyWith({
    int? id,
    int? medicationId,
    String? name,
    Value<String?> doseAmount = const Value.absent(),
    Value<String?> doseUnit = const Value.absent(),
    bool? doctorApproved,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => MedicationAlternative(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    name: name ?? this.name,
    doseAmount: doseAmount.present ? doseAmount.value : this.doseAmount,
    doseUnit: doseUnit.present ? doseUnit.value : this.doseUnit,
    doctorApproved: doctorApproved ?? this.doctorApproved,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  MedicationAlternative copyWithCompanion(
    MedicationAlternativesCompanion data,
  ) {
    return MedicationAlternative(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      name: data.name.present ? data.name.value : this.name,
      doseAmount: data.doseAmount.present
          ? data.doseAmount.value
          : this.doseAmount,
      doseUnit: data.doseUnit.present ? data.doseUnit.value : this.doseUnit,
      doctorApproved: data.doctorApproved.present
          ? data.doctorApproved.value
          : this.doctorApproved,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationAlternative(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('name: $name, ')
          ..write('doseAmount: $doseAmount, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('doctorApproved: $doctorApproved, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    name,
    doseAmount,
    doseUnit,
    doctorApproved,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationAlternative &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.name == this.name &&
          other.doseAmount == this.doseAmount &&
          other.doseUnit == this.doseUnit &&
          other.doctorApproved == this.doctorApproved &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MedicationAlternativesCompanion
    extends UpdateCompanion<MedicationAlternative> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<String> name;
  final Value<String?> doseAmount;
  final Value<String?> doseUnit;
  final Value<bool> doctorApproved;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const MedicationAlternativesCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.name = const Value.absent(),
    this.doseAmount = const Value.absent(),
    this.doseUnit = const Value.absent(),
    this.doctorApproved = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MedicationAlternativesCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required String name,
    this.doseAmount = const Value.absent(),
    this.doseUnit = const Value.absent(),
    this.doctorApproved = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
  }) : medicationId = Value(medicationId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<MedicationAlternative> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<String>? name,
    Expression<String>? doseAmount,
    Expression<String>? doseUnit,
    Expression<bool>? doctorApproved,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (name != null) 'name': name,
      if (doseAmount != null) 'dose_amount': doseAmount,
      if (doseUnit != null) 'dose_unit': doseUnit,
      if (doctorApproved != null) 'doctor_approved': doctorApproved,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MedicationAlternativesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<String>? name,
    Value<String?>? doseAmount,
    Value<String?>? doseUnit,
    Value<bool>? doctorApproved,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return MedicationAlternativesCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      name: name ?? this.name,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      doctorApproved: doctorApproved ?? this.doctorApproved,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (doseAmount.present) {
      map['dose_amount'] = Variable<String>(doseAmount.value);
    }
    if (doseUnit.present) {
      map['dose_unit'] = Variable<String>(doseUnit.value);
    }
    if (doctorApproved.present) {
      map['doctor_approved'] = Variable<bool>(doctorApproved.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationAlternativesCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('name: $name, ')
          ..write('doseAmount: $doseAmount, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('doctorApproved: $doctorApproved, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MeasurementTypesTable extends MeasurementTypes
    with TableInfo<$MeasurementTypesTable, MeasurementType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
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
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measurementCategoryMeta =
      const VerificationMeta('measurementCategory');
  @override
  late final GeneratedColumn<String> measurementCategory =
      GeneratedColumn<String>(
        'measurement_category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    unit,
    measurementCategory,
    isSystem,
    active,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
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
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('measurement_category')) {
      context.handle(
        _measurementCategoryMeta,
        measurementCategory.isAcceptableOrUnknown(
          data['measurement_category']!,
          _measurementCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measurementCategoryMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      measurementCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurement_category'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
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
  $MeasurementTypesTable createAlias(String alias) {
    return $MeasurementTypesTable(attachedDatabase, alias);
  }
}

class MeasurementType extends DataClass implements Insertable<MeasurementType> {
  final int id;
  final int? profileId;
  final String name;
  final String unit;
  final String measurementCategory;
  final bool isSystem;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MeasurementType({
    required this.id,
    this.profileId,
    required this.name,
    required this.unit,
    required this.measurementCategory,
    required this.isSystem,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['measurement_category'] = Variable<String>(measurementCategory);
    map['is_system'] = Variable<bool>(isSystem);
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MeasurementTypesCompanion toCompanion(bool nullToAbsent) {
    return MeasurementTypesCompanion(
      id: Value(id),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      name: Value(name),
      unit: Value(unit),
      measurementCategory: Value(measurementCategory),
      isSystem: Value(isSystem),
      active: Value(active),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MeasurementType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementType(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      measurementCategory: serializer.fromJson<String>(
        json['measurementCategory'],
      ),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int?>(profileId),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'measurementCategory': serializer.toJson<String>(measurementCategory),
      'isSystem': serializer.toJson<bool>(isSystem),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MeasurementType copyWith({
    int? id,
    Value<int?> profileId = const Value.absent(),
    String? name,
    String? unit,
    String? measurementCategory,
    bool? isSystem,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MeasurementType(
    id: id ?? this.id,
    profileId: profileId.present ? profileId.value : this.profileId,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    measurementCategory: measurementCategory ?? this.measurementCategory,
    isSystem: isSystem ?? this.isSystem,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MeasurementType copyWithCompanion(MeasurementTypesCompanion data) {
    return MeasurementType(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      measurementCategory: data.measurementCategory.present
          ? data.measurementCategory.value
          : this.measurementCategory,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementType(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('measurementCategory: $measurementCategory, ')
          ..write('isSystem: $isSystem, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    unit,
    measurementCategory,
    isSystem,
    active,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementType &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.measurementCategory == this.measurementCategory &&
          other.isSystem == this.isSystem &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MeasurementTypesCompanion extends UpdateCompanion<MeasurementType> {
  final Value<int> id;
  final Value<int?> profileId;
  final Value<String> name;
  final Value<String> unit;
  final Value<String> measurementCategory;
  final Value<bool> isSystem;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MeasurementTypesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.measurementCategory = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MeasurementTypesCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String name,
    required String unit,
    required String measurementCategory,
    this.isSystem = const Value.absent(),
    this.active = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       unit = Value(unit),
       measurementCategory = Value(measurementCategory),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MeasurementType> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<String>? measurementCategory,
    Expression<bool>? isSystem,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (measurementCategory != null)
        'measurement_category': measurementCategory,
      if (isSystem != null) 'is_system': isSystem,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MeasurementTypesCompanion copyWith({
    Value<int>? id,
    Value<int?>? profileId,
    Value<String>? name,
    Value<String>? unit,
    Value<String>? measurementCategory,
    Value<bool>? isSystem,
    Value<bool>? active,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MeasurementTypesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      measurementCategory: measurementCategory ?? this.measurementCategory,
      isSystem: isSystem ?? this.isSystem,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (measurementCategory.present) {
      map['measurement_category'] = Variable<String>(measurementCategory.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementTypesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('measurementCategory: $measurementCategory, ')
          ..write('isSystem: $isSystem, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MeasurementRecordsTable extends MeasurementRecords
    with TableInfo<$MeasurementRecordsTable, MeasurementRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _measurementTypeIdMeta = const VerificationMeta(
    'measurementTypeId',
  );
  @override
  late final GeneratedColumn<int> measurementTypeId = GeneratedColumn<int>(
    'measurement_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES measurement_types (id)',
    ),
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
  static const VerificationMeta _valuePrimaryMeta = const VerificationMeta(
    'valuePrimary',
  );
  @override
  late final GeneratedColumn<double> valuePrimary = GeneratedColumn<double>(
    'value_primary',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueSecondaryMeta = const VerificationMeta(
    'valueSecondary',
  );
  @override
  late final GeneratedColumn<double> valueSecondary = GeneratedColumn<double>(
    'value_secondary',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueTertiaryMeta = const VerificationMeta(
    'valueTertiary',
  );
  @override
  late final GeneratedColumn<double> valueTertiary = GeneratedColumn<double>(
    'value_tertiary',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    measurementTypeId,
    timestamp,
    valuePrimary,
    valueSecondary,
    valueTertiary,
    unit,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('measurement_type_id')) {
      context.handle(
        _measurementTypeIdMeta,
        measurementTypeId.isAcceptableOrUnknown(
          data['measurement_type_id']!,
          _measurementTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measurementTypeIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('value_primary')) {
      context.handle(
        _valuePrimaryMeta,
        valuePrimary.isAcceptableOrUnknown(
          data['value_primary']!,
          _valuePrimaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valuePrimaryMeta);
    }
    if (data.containsKey('value_secondary')) {
      context.handle(
        _valueSecondaryMeta,
        valueSecondary.isAcceptableOrUnknown(
          data['value_secondary']!,
          _valueSecondaryMeta,
        ),
      );
    }
    if (data.containsKey('value_tertiary')) {
      context.handle(
        _valueTertiaryMeta,
        valueTertiary.isAcceptableOrUnknown(
          data['value_tertiary']!,
          _valueTertiaryMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      measurementTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measurement_type_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      valuePrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_primary'],
      )!,
      valueSecondary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_secondary'],
      ),
      valueTertiary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_tertiary'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MeasurementRecordsTable createAlias(String alias) {
    return $MeasurementRecordsTable(attachedDatabase, alias);
  }
}

class MeasurementRecord extends DataClass
    implements Insertable<MeasurementRecord> {
  final int id;
  final int profileId;
  final int measurementTypeId;
  final DateTime timestamp;
  final double valuePrimary;
  final double? valueSecondary;
  final double? valueTertiary;
  final String unit;
  final String? notes;
  final DateTime createdAt;
  const MeasurementRecord({
    required this.id,
    required this.profileId,
    required this.measurementTypeId,
    required this.timestamp,
    required this.valuePrimary,
    this.valueSecondary,
    this.valueTertiary,
    required this.unit,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['measurement_type_id'] = Variable<int>(measurementTypeId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['value_primary'] = Variable<double>(valuePrimary);
    if (!nullToAbsent || valueSecondary != null) {
      map['value_secondary'] = Variable<double>(valueSecondary);
    }
    if (!nullToAbsent || valueTertiary != null) {
      map['value_tertiary'] = Variable<double>(valueTertiary);
    }
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MeasurementRecordsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementRecordsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      measurementTypeId: Value(measurementTypeId),
      timestamp: Value(timestamp),
      valuePrimary: Value(valuePrimary),
      valueSecondary: valueSecondary == null && nullToAbsent
          ? const Value.absent()
          : Value(valueSecondary),
      valueTertiary: valueTertiary == null && nullToAbsent
          ? const Value.absent()
          : Value(valueTertiary),
      unit: Value(unit),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory MeasurementRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementRecord(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      measurementTypeId: serializer.fromJson<int>(json['measurementTypeId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      valuePrimary: serializer.fromJson<double>(json['valuePrimary']),
      valueSecondary: serializer.fromJson<double?>(json['valueSecondary']),
      valueTertiary: serializer.fromJson<double?>(json['valueTertiary']),
      unit: serializer.fromJson<String>(json['unit']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'measurementTypeId': serializer.toJson<int>(measurementTypeId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'valuePrimary': serializer.toJson<double>(valuePrimary),
      'valueSecondary': serializer.toJson<double?>(valueSecondary),
      'valueTertiary': serializer.toJson<double?>(valueTertiary),
      'unit': serializer.toJson<String>(unit),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MeasurementRecord copyWith({
    int? id,
    int? profileId,
    int? measurementTypeId,
    DateTime? timestamp,
    double? valuePrimary,
    Value<double?> valueSecondary = const Value.absent(),
    Value<double?> valueTertiary = const Value.absent(),
    String? unit,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => MeasurementRecord(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    measurementTypeId: measurementTypeId ?? this.measurementTypeId,
    timestamp: timestamp ?? this.timestamp,
    valuePrimary: valuePrimary ?? this.valuePrimary,
    valueSecondary: valueSecondary.present
        ? valueSecondary.value
        : this.valueSecondary,
    valueTertiary: valueTertiary.present
        ? valueTertiary.value
        : this.valueTertiary,
    unit: unit ?? this.unit,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  MeasurementRecord copyWithCompanion(MeasurementRecordsCompanion data) {
    return MeasurementRecord(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      measurementTypeId: data.measurementTypeId.present
          ? data.measurementTypeId.value
          : this.measurementTypeId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      valuePrimary: data.valuePrimary.present
          ? data.valuePrimary.value
          : this.valuePrimary,
      valueSecondary: data.valueSecondary.present
          ? data.valueSecondary.value
          : this.valueSecondary,
      valueTertiary: data.valueTertiary.present
          ? data.valueTertiary.value
          : this.valueTertiary,
      unit: data.unit.present ? data.unit.value : this.unit,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementRecord(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('measurementTypeId: $measurementTypeId, ')
          ..write('timestamp: $timestamp, ')
          ..write('valuePrimary: $valuePrimary, ')
          ..write('valueSecondary: $valueSecondary, ')
          ..write('valueTertiary: $valueTertiary, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    measurementTypeId,
    timestamp,
    valuePrimary,
    valueSecondary,
    valueTertiary,
    unit,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementRecord &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.measurementTypeId == this.measurementTypeId &&
          other.timestamp == this.timestamp &&
          other.valuePrimary == this.valuePrimary &&
          other.valueSecondary == this.valueSecondary &&
          other.valueTertiary == this.valueTertiary &&
          other.unit == this.unit &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MeasurementRecordsCompanion extends UpdateCompanion<MeasurementRecord> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<int> measurementTypeId;
  final Value<DateTime> timestamp;
  final Value<double> valuePrimary;
  final Value<double?> valueSecondary;
  final Value<double?> valueTertiary;
  final Value<String> unit;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const MeasurementRecordsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.measurementTypeId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.valuePrimary = const Value.absent(),
    this.valueSecondary = const Value.absent(),
    this.valueTertiary = const Value.absent(),
    this.unit = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MeasurementRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required int measurementTypeId,
    required DateTime timestamp,
    required double valuePrimary,
    this.valueSecondary = const Value.absent(),
    this.valueTertiary = const Value.absent(),
    required String unit,
    this.notes = const Value.absent(),
    required DateTime createdAt,
  }) : profileId = Value(profileId),
       measurementTypeId = Value(measurementTypeId),
       timestamp = Value(timestamp),
       valuePrimary = Value(valuePrimary),
       unit = Value(unit),
       createdAt = Value(createdAt);
  static Insertable<MeasurementRecord> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<int>? measurementTypeId,
    Expression<DateTime>? timestamp,
    Expression<double>? valuePrimary,
    Expression<double>? valueSecondary,
    Expression<double>? valueTertiary,
    Expression<String>? unit,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (measurementTypeId != null) 'measurement_type_id': measurementTypeId,
      if (timestamp != null) 'timestamp': timestamp,
      if (valuePrimary != null) 'value_primary': valuePrimary,
      if (valueSecondary != null) 'value_secondary': valueSecondary,
      if (valueTertiary != null) 'value_tertiary': valueTertiary,
      if (unit != null) 'unit': unit,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MeasurementRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<int>? measurementTypeId,
    Value<DateTime>? timestamp,
    Value<double>? valuePrimary,
    Value<double?>? valueSecondary,
    Value<double?>? valueTertiary,
    Value<String>? unit,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return MeasurementRecordsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      measurementTypeId: measurementTypeId ?? this.measurementTypeId,
      timestamp: timestamp ?? this.timestamp,
      valuePrimary: valuePrimary ?? this.valuePrimary,
      valueSecondary: valueSecondary ?? this.valueSecondary,
      valueTertiary: valueTertiary ?? this.valueTertiary,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (measurementTypeId.present) {
      map['measurement_type_id'] = Variable<int>(measurementTypeId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (valuePrimary.present) {
      map['value_primary'] = Variable<double>(valuePrimary.value);
    }
    if (valueSecondary.present) {
      map['value_secondary'] = Variable<double>(valueSecondary.value);
    }
    if (valueTertiary.present) {
      map['value_tertiary'] = Variable<double>(valueTertiary.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementRecordsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('measurementTypeId: $measurementTypeId, ')
          ..write('timestamp: $timestamp, ')
          ..write('valuePrimary: $valuePrimary, ')
          ..write('valueSecondary: $valueSecondary, ')
          ..write('valueTertiary: $valueTertiary, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MeasurementSchedulesTable extends MeasurementSchedules
    with TableInfo<$MeasurementSchedulesTable, MeasurementSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _measurementTypeIdMeta = const VerificationMeta(
    'measurementTypeId',
  );
  @override
  late final GeneratedColumn<int> measurementTypeId = GeneratedColumn<int>(
    'measurement_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES measurement_types (id)',
    ),
  );
  static const VerificationMeta _scheduleConfigMeta = const VerificationMeta(
    'scheduleConfig',
  );
  @override
  late final GeneratedColumn<String> scheduleConfig = GeneratedColumn<String>(
    'schedule_config',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    measurementTypeId,
    scheduleConfig,
    startDate,
    endDate,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('measurement_type_id')) {
      context.handle(
        _measurementTypeIdMeta,
        measurementTypeId.isAcceptableOrUnknown(
          data['measurement_type_id']!,
          _measurementTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measurementTypeIdMeta);
    }
    if (data.containsKey('schedule_config')) {
      context.handle(
        _scheduleConfigMeta,
        scheduleConfig.isAcceptableOrUnknown(
          data['schedule_config']!,
          _scheduleConfigMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleConfigMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      measurementTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measurement_type_id'],
      )!,
      scheduleConfig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_config'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $MeasurementSchedulesTable createAlias(String alias) {
    return $MeasurementSchedulesTable(attachedDatabase, alias);
  }
}

class MeasurementSchedule extends DataClass
    implements Insertable<MeasurementSchedule> {
  final int id;
  final int profileId;
  final int measurementTypeId;
  final String scheduleConfig;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;
  const MeasurementSchedule({
    required this.id,
    required this.profileId,
    required this.measurementTypeId,
    required this.scheduleConfig,
    this.startDate,
    this.endDate,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['measurement_type_id'] = Variable<int>(measurementTypeId);
    map['schedule_config'] = Variable<String>(scheduleConfig);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  MeasurementSchedulesCompanion toCompanion(bool nullToAbsent) {
    return MeasurementSchedulesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      measurementTypeId: Value(measurementTypeId),
      scheduleConfig: Value(scheduleConfig),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      active: Value(active),
    );
  }

  factory MeasurementSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementSchedule(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      measurementTypeId: serializer.fromJson<int>(json['measurementTypeId']),
      scheduleConfig: serializer.fromJson<String>(json['scheduleConfig']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'measurementTypeId': serializer.toJson<int>(measurementTypeId),
      'scheduleConfig': serializer.toJson<String>(scheduleConfig),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'active': serializer.toJson<bool>(active),
    };
  }

  MeasurementSchedule copyWith({
    int? id,
    int? profileId,
    int? measurementTypeId,
    String? scheduleConfig,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    bool? active,
  }) => MeasurementSchedule(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    measurementTypeId: measurementTypeId ?? this.measurementTypeId,
    scheduleConfig: scheduleConfig ?? this.scheduleConfig,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    active: active ?? this.active,
  );
  MeasurementSchedule copyWithCompanion(MeasurementSchedulesCompanion data) {
    return MeasurementSchedule(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      measurementTypeId: data.measurementTypeId.present
          ? data.measurementTypeId.value
          : this.measurementTypeId,
      scheduleConfig: data.scheduleConfig.present
          ? data.scheduleConfig.value
          : this.scheduleConfig,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementSchedule(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('measurementTypeId: $measurementTypeId, ')
          ..write('scheduleConfig: $scheduleConfig, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    measurementTypeId,
    scheduleConfig,
    startDate,
    endDate,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementSchedule &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.measurementTypeId == this.measurementTypeId &&
          other.scheduleConfig == this.scheduleConfig &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.active == this.active);
}

class MeasurementSchedulesCompanion
    extends UpdateCompanion<MeasurementSchedule> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<int> measurementTypeId;
  final Value<String> scheduleConfig;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> active;
  const MeasurementSchedulesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.measurementTypeId = const Value.absent(),
    this.scheduleConfig = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.active = const Value.absent(),
  });
  MeasurementSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required int measurementTypeId,
    required String scheduleConfig,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.active = const Value.absent(),
  }) : profileId = Value(profileId),
       measurementTypeId = Value(measurementTypeId),
       scheduleConfig = Value(scheduleConfig);
  static Insertable<MeasurementSchedule> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<int>? measurementTypeId,
    Expression<String>? scheduleConfig,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (measurementTypeId != null) 'measurement_type_id': measurementTypeId,
      if (scheduleConfig != null) 'schedule_config': scheduleConfig,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (active != null) 'active': active,
    });
  }

  MeasurementSchedulesCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<int>? measurementTypeId,
    Value<String>? scheduleConfig,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? active,
  }) {
    return MeasurementSchedulesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      measurementTypeId: measurementTypeId ?? this.measurementTypeId,
      scheduleConfig: scheduleConfig ?? this.scheduleConfig,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (measurementTypeId.present) {
      map['measurement_type_id'] = Variable<int>(measurementTypeId.value);
    }
    if (scheduleConfig.present) {
      map['schedule_config'] = Variable<String>(scheduleConfig.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('measurementTypeId: $measurementTypeId, ')
          ..write('scheduleConfig: $scheduleConfig, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $ExerciseTypesTable extends ExerciseTypes
    with TableInfo<$ExerciseTypesTable, ExerciseType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
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
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    unit,
    notes,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $ExerciseTypesTable createAlias(String alias) {
    return $ExerciseTypesTable(attachedDatabase, alias);
  }
}

class ExerciseType extends DataClass implements Insertable<ExerciseType> {
  final int id;
  final int profileId;
  final String name;
  final String unit;
  final String? notes;
  final bool active;
  const ExerciseType({
    required this.id,
    required this.profileId,
    required this.name,
    required this.unit,
    this.notes,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  ExerciseTypesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseTypesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      unit: Value(unit),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      active: Value(active),
    );
  }

  factory ExerciseType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseType(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      notes: serializer.fromJson<String?>(json['notes']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'notes': serializer.toJson<String?>(notes),
      'active': serializer.toJson<bool>(active),
    };
  }

  ExerciseType copyWith({
    int? id,
    int? profileId,
    String? name,
    String? unit,
    Value<String?> notes = const Value.absent(),
    bool? active,
  }) => ExerciseType(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    notes: notes.present ? notes.value : this.notes,
    active: active ?? this.active,
  );
  ExerciseType copyWithCompanion(ExerciseTypesCompanion data) {
    return ExerciseType(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      notes: data.notes.present ? data.notes.value : this.notes,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseType(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, name, unit, notes, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseType &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.notes == this.notes &&
          other.active == this.active);
}

class ExerciseTypesCompanion extends UpdateCompanion<ExerciseType> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> name;
  final Value<String> unit;
  final Value<String?> notes;
  final Value<bool> active;
  const ExerciseTypesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.notes = const Value.absent(),
    this.active = const Value.absent(),
  });
  ExerciseTypesCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String name,
    required String unit,
    this.notes = const Value.absent(),
    this.active = const Value.absent(),
  }) : profileId = Value(profileId),
       name = Value(name),
       unit = Value(unit);
  static Insertable<ExerciseType> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<String>? notes,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (notes != null) 'notes': notes,
      if (active != null) 'active': active,
    });
  }

  ExerciseTypesCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? name,
    Value<String>? unit,
    Value<String?>? notes,
    Value<bool>? active,
  }) {
    return ExerciseTypesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseTypesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $ExerciseGoalsTable extends ExerciseGoals
    with TableInfo<$ExerciseGoalsTable, ExerciseGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _exerciseTypeIdMeta = const VerificationMeta(
    'exerciseTypeId',
  );
  @override
  late final GeneratedColumn<int> exerciseTypeId = GeneratedColumn<int>(
    'exercise_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise_types (id)',
    ),
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetUnitMeta = const VerificationMeta(
    'targetUnit',
  );
  @override
  late final GeneratedColumn<String> targetUnit = GeneratedColumn<String>(
    'target_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    exerciseTypeId,
    targetValue,
    targetUnit,
    frequency,
    startDate,
    endDate,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('exercise_type_id')) {
      context.handle(
        _exerciseTypeIdMeta,
        exerciseTypeId.isAcceptableOrUnknown(
          data['exercise_type_id']!,
          _exerciseTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseTypeIdMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('target_unit')) {
      context.handle(
        _targetUnitMeta,
        targetUnit.isAcceptableOrUnknown(data['target_unit']!, _targetUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_targetUnitMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      exerciseTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_type_id'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value'],
      )!,
      targetUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_unit'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $ExerciseGoalsTable createAlias(String alias) {
    return $ExerciseGoalsTable(attachedDatabase, alias);
  }
}

class ExerciseGoal extends DataClass implements Insertable<ExerciseGoal> {
  final int id;
  final int profileId;
  final int exerciseTypeId;
  final double targetValue;
  final String targetUnit;
  final String? frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;
  const ExerciseGoal({
    required this.id,
    required this.profileId,
    required this.exerciseTypeId,
    required this.targetValue,
    required this.targetUnit,
    this.frequency,
    this.startDate,
    this.endDate,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['exercise_type_id'] = Variable<int>(exerciseTypeId);
    map['target_value'] = Variable<double>(targetValue);
    map['target_unit'] = Variable<String>(targetUnit);
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<String>(frequency);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  ExerciseGoalsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseGoalsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      exerciseTypeId: Value(exerciseTypeId),
      targetValue: Value(targetValue),
      targetUnit: Value(targetUnit),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      active: Value(active),
    );
  }

  factory ExerciseGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseGoal(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      exerciseTypeId: serializer.fromJson<int>(json['exerciseTypeId']),
      targetValue: serializer.fromJson<double>(json['targetValue']),
      targetUnit: serializer.fromJson<String>(json['targetUnit']),
      frequency: serializer.fromJson<String?>(json['frequency']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'exerciseTypeId': serializer.toJson<int>(exerciseTypeId),
      'targetValue': serializer.toJson<double>(targetValue),
      'targetUnit': serializer.toJson<String>(targetUnit),
      'frequency': serializer.toJson<String?>(frequency),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'active': serializer.toJson<bool>(active),
    };
  }

  ExerciseGoal copyWith({
    int? id,
    int? profileId,
    int? exerciseTypeId,
    double? targetValue,
    String? targetUnit,
    Value<String?> frequency = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    bool? active,
  }) => ExerciseGoal(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    exerciseTypeId: exerciseTypeId ?? this.exerciseTypeId,
    targetValue: targetValue ?? this.targetValue,
    targetUnit: targetUnit ?? this.targetUnit,
    frequency: frequency.present ? frequency.value : this.frequency,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    active: active ?? this.active,
  );
  ExerciseGoal copyWithCompanion(ExerciseGoalsCompanion data) {
    return ExerciseGoal(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      exerciseTypeId: data.exerciseTypeId.present
          ? data.exerciseTypeId.value
          : this.exerciseTypeId,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      targetUnit: data.targetUnit.present
          ? data.targetUnit.value
          : this.targetUnit,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseGoal(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('exerciseTypeId: $exerciseTypeId, ')
          ..write('targetValue: $targetValue, ')
          ..write('targetUnit: $targetUnit, ')
          ..write('frequency: $frequency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    exerciseTypeId,
    targetValue,
    targetUnit,
    frequency,
    startDate,
    endDate,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseGoal &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.exerciseTypeId == this.exerciseTypeId &&
          other.targetValue == this.targetValue &&
          other.targetUnit == this.targetUnit &&
          other.frequency == this.frequency &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.active == this.active);
}

class ExerciseGoalsCompanion extends UpdateCompanion<ExerciseGoal> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<int> exerciseTypeId;
  final Value<double> targetValue;
  final Value<String> targetUnit;
  final Value<String?> frequency;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> active;
  const ExerciseGoalsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.exerciseTypeId = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.targetUnit = const Value.absent(),
    this.frequency = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.active = const Value.absent(),
  });
  ExerciseGoalsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required int exerciseTypeId,
    required double targetValue,
    required String targetUnit,
    this.frequency = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.active = const Value.absent(),
  }) : profileId = Value(profileId),
       exerciseTypeId = Value(exerciseTypeId),
       targetValue = Value(targetValue),
       targetUnit = Value(targetUnit);
  static Insertable<ExerciseGoal> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<int>? exerciseTypeId,
    Expression<double>? targetValue,
    Expression<String>? targetUnit,
    Expression<String>? frequency,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (exerciseTypeId != null) 'exercise_type_id': exerciseTypeId,
      if (targetValue != null) 'target_value': targetValue,
      if (targetUnit != null) 'target_unit': targetUnit,
      if (frequency != null) 'frequency': frequency,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (active != null) 'active': active,
    });
  }

  ExerciseGoalsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<int>? exerciseTypeId,
    Value<double>? targetValue,
    Value<String>? targetUnit,
    Value<String?>? frequency,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? active,
  }) {
    return ExerciseGoalsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      exerciseTypeId: exerciseTypeId ?? this.exerciseTypeId,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (exerciseTypeId.present) {
      map['exercise_type_id'] = Variable<int>(exerciseTypeId.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (targetUnit.present) {
      map['target_unit'] = Variable<String>(targetUnit.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseGoalsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('exerciseTypeId: $exerciseTypeId, ')
          ..write('targetValue: $targetValue, ')
          ..write('targetUnit: $targetUnit, ')
          ..write('frequency: $frequency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $ExerciseLogsTable extends ExerciseLogs
    with TableInfo<$ExerciseLogsTable, ExerciseLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _exerciseTypeIdMeta = const VerificationMeta(
    'exerciseTypeId',
  );
  @override
  late final GeneratedColumn<int> exerciseTypeId = GeneratedColumn<int>(
    'exercise_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise_types (id)',
    ),
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMeta = const VerificationMeta(
    'distance',
  );
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
    'distance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    exerciseTypeId,
    logDate,
    durationMinutes,
    distance,
    calories,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('exercise_type_id')) {
      context.handle(
        _exerciseTypeIdMeta,
        exerciseTypeId.isAcceptableOrUnknown(
          data['exercise_type_id']!,
          _exerciseTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseTypeIdMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('distance')) {
      context.handle(
        _distanceMeta,
        distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      exerciseTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_type_id'],
      )!,
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
      distance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance'],
      ),
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ExerciseLogsTable createAlias(String alias) {
    return $ExerciseLogsTable(attachedDatabase, alias);
  }
}

class ExerciseLog extends DataClass implements Insertable<ExerciseLog> {
  final int id;
  final int profileId;
  final int exerciseTypeId;
  final DateTime logDate;
  final int? durationMinutes;
  final double? distance;
  final int? calories;
  final String? notes;
  const ExerciseLog({
    required this.id,
    required this.profileId,
    required this.exerciseTypeId,
    required this.logDate,
    this.durationMinutes,
    this.distance,
    this.calories,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['exercise_type_id'] = Variable<int>(exerciseTypeId);
    map['log_date'] = Variable<DateTime>(logDate);
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<double>(distance);
    }
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<int>(calories);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ExerciseLogsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseLogsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      exerciseTypeId: Value(exerciseTypeId),
      logDate: Value(logDate),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      distance: distance == null && nullToAbsent
          ? const Value.absent()
          : Value(distance),
      calories: calories == null && nullToAbsent
          ? const Value.absent()
          : Value(calories),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory ExerciseLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseLog(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      exerciseTypeId: serializer.fromJson<int>(json['exerciseTypeId']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      distance: serializer.fromJson<double?>(json['distance']),
      calories: serializer.fromJson<int?>(json['calories']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'exerciseTypeId': serializer.toJson<int>(exerciseTypeId),
      'logDate': serializer.toJson<DateTime>(logDate),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'distance': serializer.toJson<double?>(distance),
      'calories': serializer.toJson<int?>(calories),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ExerciseLog copyWith({
    int? id,
    int? profileId,
    int? exerciseTypeId,
    DateTime? logDate,
    Value<int?> durationMinutes = const Value.absent(),
    Value<double?> distance = const Value.absent(),
    Value<int?> calories = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => ExerciseLog(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    exerciseTypeId: exerciseTypeId ?? this.exerciseTypeId,
    logDate: logDate ?? this.logDate,
    durationMinutes: durationMinutes.present
        ? durationMinutes.value
        : this.durationMinutes,
    distance: distance.present ? distance.value : this.distance,
    calories: calories.present ? calories.value : this.calories,
    notes: notes.present ? notes.value : this.notes,
  );
  ExerciseLog copyWithCompanion(ExerciseLogsCompanion data) {
    return ExerciseLog(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      exerciseTypeId: data.exerciseTypeId.present
          ? data.exerciseTypeId.value
          : this.exerciseTypeId,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      distance: data.distance.present ? data.distance.value : this.distance,
      calories: data.calories.present ? data.calories.value : this.calories,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseLog(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('exerciseTypeId: $exerciseTypeId, ')
          ..write('logDate: $logDate, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('distance: $distance, ')
          ..write('calories: $calories, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    exerciseTypeId,
    logDate,
    durationMinutes,
    distance,
    calories,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseLog &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.exerciseTypeId == this.exerciseTypeId &&
          other.logDate == this.logDate &&
          other.durationMinutes == this.durationMinutes &&
          other.distance == this.distance &&
          other.calories == this.calories &&
          other.notes == this.notes);
}

class ExerciseLogsCompanion extends UpdateCompanion<ExerciseLog> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<int> exerciseTypeId;
  final Value<DateTime> logDate;
  final Value<int?> durationMinutes;
  final Value<double?> distance;
  final Value<int?> calories;
  final Value<String?> notes;
  const ExerciseLogsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.exerciseTypeId = const Value.absent(),
    this.logDate = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.distance = const Value.absent(),
    this.calories = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ExerciseLogsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required int exerciseTypeId,
    required DateTime logDate,
    this.durationMinutes = const Value.absent(),
    this.distance = const Value.absent(),
    this.calories = const Value.absent(),
    this.notes = const Value.absent(),
  }) : profileId = Value(profileId),
       exerciseTypeId = Value(exerciseTypeId),
       logDate = Value(logDate);
  static Insertable<ExerciseLog> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<int>? exerciseTypeId,
    Expression<DateTime>? logDate,
    Expression<int>? durationMinutes,
    Expression<double>? distance,
    Expression<int>? calories,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (exerciseTypeId != null) 'exercise_type_id': exerciseTypeId,
      if (logDate != null) 'log_date': logDate,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (distance != null) 'distance': distance,
      if (calories != null) 'calories': calories,
      if (notes != null) 'notes': notes,
    });
  }

  ExerciseLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<int>? exerciseTypeId,
    Value<DateTime>? logDate,
    Value<int?>? durationMinutes,
    Value<double?>? distance,
    Value<int?>? calories,
    Value<String?>? notes,
  }) {
    return ExerciseLogsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      exerciseTypeId: exerciseTypeId ?? this.exerciseTypeId,
      logDate: logDate ?? this.logDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (exerciseTypeId.present) {
      map['exercise_type_id'] = Variable<int>(exerciseTypeId.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseLogsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('exerciseTypeId: $exerciseTypeId, ')
          ..write('logDate: $logDate, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('distance: $distance, ')
          ..write('calories: $calories, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $DoctorsTable extends Doctors with TableInfo<$DoctorsTable, Doctor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoctorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specialtyMeta = const VerificationMeta(
    'specialty',
  );
  @override
  late final GeneratedColumn<String> specialty = GeneratedColumn<String>(
    'specialty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicMeta = const VerificationMeta('clinic');
  @override
  late final GeneratedColumn<String> clinic = GeneratedColumn<String>(
    'clinic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    firstName,
    lastName,
    specialty,
    phone,
    email,
    clinic,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doctors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Doctor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('specialty')) {
      context.handle(
        _specialtyMeta,
        specialty.isAcceptableOrUnknown(data['specialty']!, _specialtyMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('clinic')) {
      context.handle(
        _clinicMeta,
        clinic.isAcceptableOrUnknown(data['clinic']!, _clinicMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Doctor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Doctor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      specialty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialty'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      clinic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DoctorsTable createAlias(String alias) {
    return $DoctorsTable(attachedDatabase, alias);
  }
}

class Doctor extends DataClass implements Insertable<Doctor> {
  final int id;
  final int profileId;
  final String firstName;
  final String lastName;
  final String? specialty;
  final String? phone;
  final String? email;
  final String? clinic;
  final String? notes;
  const Doctor({
    required this.id,
    required this.profileId,
    required this.firstName,
    required this.lastName,
    this.specialty,
    this.phone,
    this.email,
    this.clinic,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || specialty != null) {
      map['specialty'] = Variable<String>(specialty);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || clinic != null) {
      map['clinic'] = Variable<String>(clinic);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DoctorsCompanion toCompanion(bool nullToAbsent) {
    return DoctorsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      firstName: Value(firstName),
      lastName: Value(lastName),
      specialty: specialty == null && nullToAbsent
          ? const Value.absent()
          : Value(specialty),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      clinic: clinic == null && nullToAbsent
          ? const Value.absent()
          : Value(clinic),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Doctor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Doctor(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      specialty: serializer.fromJson<String?>(json['specialty']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      clinic: serializer.fromJson<String?>(json['clinic']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'specialty': serializer.toJson<String?>(specialty),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'clinic': serializer.toJson<String?>(clinic),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Doctor copyWith({
    int? id,
    int? profileId,
    String? firstName,
    String? lastName,
    Value<String?> specialty = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> clinic = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Doctor(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    specialty: specialty.present ? specialty.value : this.specialty,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    clinic: clinic.present ? clinic.value : this.clinic,
    notes: notes.present ? notes.value : this.notes,
  );
  Doctor copyWithCompanion(DoctorsCompanion data) {
    return Doctor(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      clinic: data.clinic.present ? data.clinic.value : this.clinic,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Doctor(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('specialty: $specialty, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('clinic: $clinic, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    firstName,
    lastName,
    specialty,
    phone,
    email,
    clinic,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Doctor &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.specialty == this.specialty &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.clinic == this.clinic &&
          other.notes == this.notes);
}

class DoctorsCompanion extends UpdateCompanion<Doctor> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String?> specialty;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> clinic;
  final Value<String?> notes;
  const DoctorsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.specialty = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.clinic = const Value.absent(),
    this.notes = const Value.absent(),
  });
  DoctorsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String firstName,
    required String lastName,
    this.specialty = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.clinic = const Value.absent(),
    this.notes = const Value.absent(),
  }) : profileId = Value(profileId),
       firstName = Value(firstName),
       lastName = Value(lastName);
  static Insertable<Doctor> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? specialty,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? clinic,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (specialty != null) 'specialty': specialty,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (clinic != null) 'clinic': clinic,
      if (notes != null) 'notes': notes,
    });
  }

  DoctorsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String?>? specialty,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? clinic,
    Value<String?>? notes,
  }) {
    return DoctorsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      specialty: specialty ?? this.specialty,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      clinic: clinic ?? this.clinic,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (specialty.present) {
      map['specialty'] = Variable<String>(specialty.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (clinic.present) {
      map['clinic'] = Variable<String>(clinic.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoctorsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('specialty: $specialty, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('clinic: $clinic, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $DoctorVisitsTable extends DoctorVisits
    with TableInfo<$DoctorVisitsTable, DoctorVisit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoctorVisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _doctorIdMeta = const VerificationMeta(
    'doctorId',
  );
  @override
  late final GeneratedColumn<int> doctorId = GeneratedColumn<int>(
    'doctor_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES doctors (id)',
    ),
  );
  static const VerificationMeta _visitDateMeta = const VerificationMeta(
    'visitDate',
  );
  @override
  late final GeneratedColumn<DateTime> visitDate = GeneratedColumn<DateTime>(
    'visit_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderMinutesBeforeMeta =
      const VerificationMeta('reminderMinutesBefore');
  @override
  late final GeneratedColumn<int> reminderMinutesBefore = GeneratedColumn<int>(
    'reminder_minutes_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    doctorId,
    visitDate,
    status,
    reason,
    notes,
    reminderEnabled,
    reminderMinutesBefore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doctor_visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoctorVisit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('doctor_id')) {
      context.handle(
        _doctorIdMeta,
        doctorId.isAcceptableOrUnknown(data['doctor_id']!, _doctorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_doctorIdMeta);
    }
    if (data.containsKey('visit_date')) {
      context.handle(
        _visitDateMeta,
        visitDate.isAcceptableOrUnknown(data['visit_date']!, _visitDateMeta),
      );
    } else if (isInserting) {
      context.missing(_visitDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minutes_before')) {
      context.handle(
        _reminderMinutesBeforeMeta,
        reminderMinutesBefore.isAcceptableOrUnknown(
          data['reminder_minutes_before']!,
          _reminderMinutesBeforeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DoctorVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoctorVisit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      doctorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}doctor_id'],
      )!,
      visitDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visit_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderMinutesBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minutes_before'],
      )!,
    );
  }

  @override
  $DoctorVisitsTable createAlias(String alias) {
    return $DoctorVisitsTable(attachedDatabase, alias);
  }
}

class DoctorVisit extends DataClass implements Insertable<DoctorVisit> {
  final int id;
  final int profileId;
  final int doctorId;
  final DateTime visitDate;
  final String status;
  final String? reason;
  final String? notes;
  final bool reminderEnabled;
  final int reminderMinutesBefore;
  const DoctorVisit({
    required this.id,
    required this.profileId,
    required this.doctorId,
    required this.visitDate,
    required this.status,
    this.reason,
    this.notes,
    required this.reminderEnabled,
    required this.reminderMinutesBefore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['doctor_id'] = Variable<int>(doctorId);
    map['visit_date'] = Variable<DateTime>(visitDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['reminder_minutes_before'] = Variable<int>(reminderMinutesBefore);
    return map;
  }

  DoctorVisitsCompanion toCompanion(bool nullToAbsent) {
    return DoctorVisitsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      doctorId: Value(doctorId),
      visitDate: Value(visitDate),
      status: Value(status),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      reminderEnabled: Value(reminderEnabled),
      reminderMinutesBefore: Value(reminderMinutesBefore),
    );
  }

  factory DoctorVisit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoctorVisit(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      doctorId: serializer.fromJson<int>(json['doctorId']),
      visitDate: serializer.fromJson<DateTime>(json['visitDate']),
      status: serializer.fromJson<String>(json['status']),
      reason: serializer.fromJson<String?>(json['reason']),
      notes: serializer.fromJson<String?>(json['notes']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderMinutesBefore: serializer.fromJson<int>(
        json['reminderMinutesBefore'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'doctorId': serializer.toJson<int>(doctorId),
      'visitDate': serializer.toJson<DateTime>(visitDate),
      'status': serializer.toJson<String>(status),
      'reason': serializer.toJson<String?>(reason),
      'notes': serializer.toJson<String?>(notes),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderMinutesBefore': serializer.toJson<int>(reminderMinutesBefore),
    };
  }

  DoctorVisit copyWith({
    int? id,
    int? profileId,
    int? doctorId,
    DateTime? visitDate,
    String? status,
    Value<String?> reason = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? reminderEnabled,
    int? reminderMinutesBefore,
  }) => DoctorVisit(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    doctorId: doctorId ?? this.doctorId,
    visitDate: visitDate ?? this.visitDate,
    status: status ?? this.status,
    reason: reason.present ? reason.value : this.reason,
    notes: notes.present ? notes.value : this.notes,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
  );
  DoctorVisit copyWithCompanion(DoctorVisitsCompanion data) {
    return DoctorVisit(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      doctorId: data.doctorId.present ? data.doctorId.value : this.doctorId,
      visitDate: data.visitDate.present ? data.visitDate.value : this.visitDate,
      status: data.status.present ? data.status.value : this.status,
      reason: data.reason.present ? data.reason.value : this.reason,
      notes: data.notes.present ? data.notes.value : this.notes,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderMinutesBefore: data.reminderMinutesBefore.present
          ? data.reminderMinutesBefore.value
          : this.reminderMinutesBefore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoctorVisit(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('doctorId: $doctorId, ')
          ..write('visitDate: $visitDate, ')
          ..write('status: $status, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    doctorId,
    visitDate,
    status,
    reason,
    notes,
    reminderEnabled,
    reminderMinutesBefore,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoctorVisit &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.doctorId == this.doctorId &&
          other.visitDate == this.visitDate &&
          other.status == this.status &&
          other.reason == this.reason &&
          other.notes == this.notes &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderMinutesBefore == this.reminderMinutesBefore);
}

class DoctorVisitsCompanion extends UpdateCompanion<DoctorVisit> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<int> doctorId;
  final Value<DateTime> visitDate;
  final Value<String> status;
  final Value<String?> reason;
  final Value<String?> notes;
  final Value<bool> reminderEnabled;
  final Value<int> reminderMinutesBefore;
  const DoctorVisitsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.doctorId = const Value.absent(),
    this.visitDate = const Value.absent(),
    this.status = const Value.absent(),
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
  });
  DoctorVisitsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required int doctorId,
    required DateTime visitDate,
    required String status,
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
  }) : profileId = Value(profileId),
       doctorId = Value(doctorId),
       visitDate = Value(visitDate),
       status = Value(status);
  static Insertable<DoctorVisit> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<int>? doctorId,
    Expression<DateTime>? visitDate,
    Expression<String>? status,
    Expression<String>? reason,
    Expression<String>? notes,
    Expression<bool>? reminderEnabled,
    Expression<int>? reminderMinutesBefore,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (doctorId != null) 'doctor_id': doctorId,
      if (visitDate != null) 'visit_date': visitDate,
      if (status != null) 'status': status,
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderMinutesBefore != null)
        'reminder_minutes_before': reminderMinutesBefore,
    });
  }

  DoctorVisitsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<int>? doctorId,
    Value<DateTime>? visitDate,
    Value<String>? status,
    Value<String?>? reason,
    Value<String?>? notes,
    Value<bool>? reminderEnabled,
    Value<int>? reminderMinutesBefore,
  }) {
    return DoctorVisitsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      doctorId: doctorId ?? this.doctorId,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (doctorId.present) {
      map['doctor_id'] = Variable<int>(doctorId.value);
    }
    if (visitDate.present) {
      map['visit_date'] = Variable<DateTime>(visitDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderMinutesBefore.present) {
      map['reminder_minutes_before'] = Variable<int>(
        reminderMinutesBefore.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoctorVisitsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('doctorId: $doctorId, ')
          ..write('visitDate: $visitDate, ')
          ..write('status: $status, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore')
          ..write(')'))
        .toString();
  }
}

class $DocumentAttachmentsTable extends DocumentAttachments
    with TableInfo<$DocumentAttachmentsTable, DocumentAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
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
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storedPathMeta = const VerificationMeta(
    'storedPath',
  );
  @override
  late final GeneratedColumn<String> storedPath = GeneratedColumn<String>(
    'stored_path',
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
    true,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    category,
    title,
    fileName,
    mimeType,
    storedPath,
    fileSize,
    createdAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('stored_path')) {
      context.handle(
        _storedPathMeta,
        storedPath.isAcceptableOrUnknown(data['stored_path']!, _storedPathMeta),
      );
    } else if (isInserting) {
      context.missing(_storedPathMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      storedPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stored_path'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DocumentAttachmentsTable createAlias(String alias) {
    return $DocumentAttachmentsTable(attachedDatabase, alias);
  }
}

class DocumentAttachment extends DataClass
    implements Insertable<DocumentAttachment> {
  final int id;
  final int profileId;
  final String category;
  final String title;
  final String fileName;
  final String mimeType;
  final String storedPath;
  final int? fileSize;
  final DateTime createdAt;
  final String? notes;
  const DocumentAttachment({
    required this.id,
    required this.profileId,
    required this.category,
    required this.title,
    required this.fileName,
    required this.mimeType,
    required this.storedPath,
    this.fileSize,
    required this.createdAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['category'] = Variable<String>(category);
    map['title'] = Variable<String>(title);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    map['stored_path'] = Variable<String>(storedPath);
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DocumentAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentAttachmentsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      category: Value(category),
      title: Value(title),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      storedPath: Value(storedPath),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      createdAt: Value(createdAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DocumentAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentAttachment(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      category: serializer.fromJson<String>(json['category']),
      title: serializer.fromJson<String>(json['title']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      storedPath: serializer.fromJson<String>(json['storedPath']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'category': serializer.toJson<String>(category),
      'title': serializer.toJson<String>(title),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'storedPath': serializer.toJson<String>(storedPath),
      'fileSize': serializer.toJson<int?>(fileSize),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DocumentAttachment copyWith({
    int? id,
    int? profileId,
    String? category,
    String? title,
    String? fileName,
    String? mimeType,
    String? storedPath,
    Value<int?> fileSize = const Value.absent(),
    DateTime? createdAt,
    Value<String?> notes = const Value.absent(),
  }) => DocumentAttachment(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    category: category ?? this.category,
    title: title ?? this.title,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    storedPath: storedPath ?? this.storedPath,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    createdAt: createdAt ?? this.createdAt,
    notes: notes.present ? notes.value : this.notes,
  );
  DocumentAttachment copyWithCompanion(DocumentAttachmentsCompanion data) {
    return DocumentAttachment(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      storedPath: data.storedPath.present
          ? data.storedPath.value
          : this.storedPath,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentAttachment(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('storedPath: $storedPath, ')
          ..write('fileSize: $fileSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    category,
    title,
    fileName,
    mimeType,
    storedPath,
    fileSize,
    createdAt,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentAttachment &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.category == this.category &&
          other.title == this.title &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.storedPath == this.storedPath &&
          other.fileSize == this.fileSize &&
          other.createdAt == this.createdAt &&
          other.notes == this.notes);
}

class DocumentAttachmentsCompanion extends UpdateCompanion<DocumentAttachment> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> category;
  final Value<String> title;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<String> storedPath;
  final Value<int?> fileSize;
  final Value<DateTime> createdAt;
  final Value<String?> notes;
  const DocumentAttachmentsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.storedPath = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  DocumentAttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String category,
    required String title,
    required String fileName,
    required String mimeType,
    required String storedPath,
    this.fileSize = const Value.absent(),
    required DateTime createdAt,
    this.notes = const Value.absent(),
  }) : profileId = Value(profileId),
       category = Value(category),
       title = Value(title),
       fileName = Value(fileName),
       mimeType = Value(mimeType),
       storedPath = Value(storedPath),
       createdAt = Value(createdAt);
  static Insertable<DocumentAttachment> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<String>? storedPath,
    Expression<int>? fileSize,
    Expression<DateTime>? createdAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (storedPath != null) 'stored_path': storedPath,
      if (fileSize != null) 'file_size': fileSize,
      if (createdAt != null) 'created_at': createdAt,
      if (notes != null) 'notes': notes,
    });
  }

  DocumentAttachmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? category,
    Value<String>? title,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<String>? storedPath,
    Value<int?>? fileSize,
    Value<DateTime>? createdAt,
    Value<String?>? notes,
  }) {
    return DocumentAttachmentsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      category: category ?? this.category,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      storedPath: storedPath ?? this.storedPath,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (storedPath.present) {
      map['stored_path'] = Variable<String>(storedPath.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('storedPath: $storedPath, ')
          ..write('fileSize: $fileSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $DietPlansTable extends DietPlans
    with TableInfo<$DietPlansTable, DietPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DietPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
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
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    title,
    description,
    startDate,
    endDate,
    active,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diet_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<DietPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DietPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DietPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DietPlansTable createAlias(String alias) {
    return $DietPlansTable(attachedDatabase, alias);
  }
}

class DietPlan extends DataClass implements Insertable<DietPlan> {
  final int id;
  final int profileId;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;
  final String? notes;
  const DietPlan({
    required this.id,
    required this.profileId,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    required this.active,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DietPlansCompanion toCompanion(bool nullToAbsent) {
    return DietPlansCompanion(
      id: Value(id),
      profileId: Value(profileId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      active: Value(active),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DietPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DietPlan(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      active: serializer.fromJson<bool>(json['active']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'active': serializer.toJson<bool>(active),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DietPlan copyWith({
    int? id,
    int? profileId,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    bool? active,
    Value<String?> notes = const Value.absent(),
  }) => DietPlan(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    active: active ?? this.active,
    notes: notes.present ? notes.value : this.notes,
  );
  DietPlan copyWithCompanion(DietPlansCompanion data) {
    return DietPlan(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      active: data.active.present ? data.active.value : this.active,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DietPlan(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('active: $active, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    title,
    description,
    startDate,
    endDate,
    active,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DietPlan &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.title == this.title &&
          other.description == this.description &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.active == this.active &&
          other.notes == this.notes);
}

class DietPlansCompanion extends UpdateCompanion<DietPlan> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> active;
  final Value<String?> notes;
  const DietPlansCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.active = const Value.absent(),
    this.notes = const Value.absent(),
  });
  DietPlansCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String title,
    this.description = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.active = const Value.absent(),
    this.notes = const Value.absent(),
  }) : profileId = Value(profileId),
       title = Value(title);
  static Insertable<DietPlan> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? active,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (active != null) 'active': active,
      if (notes != null) 'notes': notes,
    });
  }

  DietPlansCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? active,
    Value<String?>? notes,
  }) {
    return DietPlansCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DietPlansCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('active: $active, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $DietItemsTable extends DietItems
    with TableInfo<$DietItemsTable, DietItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DietItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dietPlanIdMeta = const VerificationMeta(
    'dietPlanId',
  );
  @override
  late final GeneratedColumn<int> dietPlanId = GeneratedColumn<int>(
    'diet_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES diet_plans (id)',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTextMeta = const VerificationMeta(
    'itemText',
  );
  @override
  late final GeneratedColumn<String> itemText = GeneratedColumn<String>(
    'item_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dietPlanId,
    category,
    itemText,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diet_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DietItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('diet_plan_id')) {
      context.handle(
        _dietPlanIdMeta,
        dietPlanId.isAcceptableOrUnknown(
          data['diet_plan_id']!,
          _dietPlanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dietPlanIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('item_text')) {
      context.handle(
        _itemTextMeta,
        itemText.isAcceptableOrUnknown(data['item_text']!, _itemTextMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTextMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DietItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DietItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dietPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diet_plan_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      itemText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_text'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DietItemsTable createAlias(String alias) {
    return $DietItemsTable(attachedDatabase, alias);
  }
}

class DietItem extends DataClass implements Insertable<DietItem> {
  final int id;
  final int dietPlanId;
  final String category;
  final String itemText;
  final String? notes;
  const DietItem({
    required this.id,
    required this.dietPlanId,
    required this.category,
    required this.itemText,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['diet_plan_id'] = Variable<int>(dietPlanId);
    map['category'] = Variable<String>(category);
    map['item_text'] = Variable<String>(itemText);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DietItemsCompanion toCompanion(bool nullToAbsent) {
    return DietItemsCompanion(
      id: Value(id),
      dietPlanId: Value(dietPlanId),
      category: Value(category),
      itemText: Value(itemText),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DietItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DietItem(
      id: serializer.fromJson<int>(json['id']),
      dietPlanId: serializer.fromJson<int>(json['dietPlanId']),
      category: serializer.fromJson<String>(json['category']),
      itemText: serializer.fromJson<String>(json['itemText']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dietPlanId': serializer.toJson<int>(dietPlanId),
      'category': serializer.toJson<String>(category),
      'itemText': serializer.toJson<String>(itemText),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DietItem copyWith({
    int? id,
    int? dietPlanId,
    String? category,
    String? itemText,
    Value<String?> notes = const Value.absent(),
  }) => DietItem(
    id: id ?? this.id,
    dietPlanId: dietPlanId ?? this.dietPlanId,
    category: category ?? this.category,
    itemText: itemText ?? this.itemText,
    notes: notes.present ? notes.value : this.notes,
  );
  DietItem copyWithCompanion(DietItemsCompanion data) {
    return DietItem(
      id: data.id.present ? data.id.value : this.id,
      dietPlanId: data.dietPlanId.present
          ? data.dietPlanId.value
          : this.dietPlanId,
      category: data.category.present ? data.category.value : this.category,
      itemText: data.itemText.present ? data.itemText.value : this.itemText,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DietItem(')
          ..write('id: $id, ')
          ..write('dietPlanId: $dietPlanId, ')
          ..write('category: $category, ')
          ..write('itemText: $itemText, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dietPlanId, category, itemText, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DietItem &&
          other.id == this.id &&
          other.dietPlanId == this.dietPlanId &&
          other.category == this.category &&
          other.itemText == this.itemText &&
          other.notes == this.notes);
}

class DietItemsCompanion extends UpdateCompanion<DietItem> {
  final Value<int> id;
  final Value<int> dietPlanId;
  final Value<String> category;
  final Value<String> itemText;
  final Value<String?> notes;
  const DietItemsCompanion({
    this.id = const Value.absent(),
    this.dietPlanId = const Value.absent(),
    this.category = const Value.absent(),
    this.itemText = const Value.absent(),
    this.notes = const Value.absent(),
  });
  DietItemsCompanion.insert({
    this.id = const Value.absent(),
    required int dietPlanId,
    required String category,
    required String itemText,
    this.notes = const Value.absent(),
  }) : dietPlanId = Value(dietPlanId),
       category = Value(category),
       itemText = Value(itemText);
  static Insertable<DietItem> custom({
    Expression<int>? id,
    Expression<int>? dietPlanId,
    Expression<String>? category,
    Expression<String>? itemText,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dietPlanId != null) 'diet_plan_id': dietPlanId,
      if (category != null) 'category': category,
      if (itemText != null) 'item_text': itemText,
      if (notes != null) 'notes': notes,
    });
  }

  DietItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? dietPlanId,
    Value<String>? category,
    Value<String>? itemText,
    Value<String?>? notes,
  }) {
    return DietItemsCompanion(
      id: id ?? this.id,
      dietPlanId: dietPlanId ?? this.dietPlanId,
      category: category ?? this.category,
      itemText: itemText ?? this.itemText,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dietPlanId.present) {
      map['diet_plan_id'] = Variable<int>(dietPlanId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (itemText.present) {
      map['item_text'] = Variable<String>(itemText.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DietItemsCompanion(')
          ..write('id: $id, ')
          ..write('dietPlanId: $dietPlanId, ')
          ..write('category: $category, ')
          ..write('itemText: $itemText, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $HealthTemplatesTable extends HealthTemplates
    with TableInfo<$HealthTemplatesTable, HealthTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configurationJsonMeta = const VerificationMeta(
    'configurationJson',
  );
  @override
  late final GeneratedColumn<String> configurationJson =
      GeneratedColumn<String>(
        'configuration_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    configurationJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('configuration_json')) {
      context.handle(
        _configurationJsonMeta,
        configurationJson.isAcceptableOrUnknown(
          data['configuration_json']!,
          _configurationJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_configurationJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      configurationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}configuration_json'],
      )!,
    );
  }

  @override
  $HealthTemplatesTable createAlias(String alias) {
    return $HealthTemplatesTable(attachedDatabase, alias);
  }
}

class HealthTemplate extends DataClass implements Insertable<HealthTemplate> {
  final int id;
  final String name;
  final String description;
  final String configurationJson;
  const HealthTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.configurationJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['configuration_json'] = Variable<String>(configurationJson);
    return map;
  }

  HealthTemplatesCompanion toCompanion(bool nullToAbsent) {
    return HealthTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      configurationJson: Value(configurationJson),
    );
  }

  factory HealthTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthTemplate(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      configurationJson: serializer.fromJson<String>(json['configurationJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'configurationJson': serializer.toJson<String>(configurationJson),
    };
  }

  HealthTemplate copyWith({
    int? id,
    String? name,
    String? description,
    String? configurationJson,
  }) => HealthTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    configurationJson: configurationJson ?? this.configurationJson,
  );
  HealthTemplate copyWithCompanion(HealthTemplatesCompanion data) {
    return HealthTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      configurationJson: data.configurationJson.present
          ? data.configurationJson.value
          : this.configurationJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('configurationJson: $configurationJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, configurationJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.configurationJson == this.configurationJson);
}

class HealthTemplatesCompanion extends UpdateCompanion<HealthTemplate> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> configurationJson;
  const HealthTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.configurationJson = const Value.absent(),
  });
  HealthTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String description,
    required String configurationJson,
  }) : name = Value(name),
       description = Value(description),
       configurationJson = Value(configurationJson);
  static Insertable<HealthTemplate> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? configurationJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (configurationJson != null) 'configuration_json': configurationJson,
    });
  }

  HealthTemplatesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? configurationJson,
  }) {
    return HealthTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      configurationJson: configurationJson ?? this.configurationJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (configurationJson.present) {
      map['configuration_json'] = Variable<String>(configurationJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('configurationJson: $configurationJson')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
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
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
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
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
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

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
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

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $MedicationSchedulesTable medicationSchedules =
      $MedicationSchedulesTable(this);
  late final $MedicationLogsTable medicationLogs = $MedicationLogsTable(this);
  late final $MedicationAlternativesTable medicationAlternatives =
      $MedicationAlternativesTable(this);
  late final $MeasurementTypesTable measurementTypes = $MeasurementTypesTable(
    this,
  );
  late final $MeasurementRecordsTable measurementRecords =
      $MeasurementRecordsTable(this);
  late final $MeasurementSchedulesTable measurementSchedules =
      $MeasurementSchedulesTable(this);
  late final $ExerciseTypesTable exerciseTypes = $ExerciseTypesTable(this);
  late final $ExerciseGoalsTable exerciseGoals = $ExerciseGoalsTable(this);
  late final $ExerciseLogsTable exerciseLogs = $ExerciseLogsTable(this);
  late final $DoctorsTable doctors = $DoctorsTable(this);
  late final $DoctorVisitsTable doctorVisits = $DoctorVisitsTable(this);
  late final $DocumentAttachmentsTable documentAttachments =
      $DocumentAttachmentsTable(this);
  late final $DietPlansTable dietPlans = $DietPlansTable(this);
  late final $DietItemsTable dietItems = $DietItemsTable(this);
  late final $HealthTemplatesTable healthTemplates = $HealthTemplatesTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    medications,
    medicationSchedules,
    medicationLogs,
    medicationAlternatives,
    measurementTypes,
    measurementRecords,
    measurementSchedules,
    exerciseTypes,
    exerciseGoals,
    exerciseLogs,
    doctors,
    doctorVisits,
    documentAttachments,
    dietPlans,
    dietItems,
    healthTemplates,
    appSettings,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required String firstName,
      required String lastName,
      Value<DateTime?> birthDate,
      Value<String?> gender,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<String?> bloodType,
      Value<String?> allergies,
      Value<String?> emergencyContactName,
      Value<String?> emergencyContactPhone,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> firstName,
      Value<String> lastName,
      Value<DateTime?> birthDate,
      Value<String?> gender,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<String?> bloodType,
      Value<String?> allergies,
      Value<String?> emergencyContactName,
      Value<String?> emergencyContactPhone,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MedicationsTable, List<Medication>>
  _medicationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medications,
    aliasName: 'profiles__id__medications__profile_id',
  );

  $$MedicationsTableProcessedTableManager get medicationsRefs {
    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MeasurementTypesTable, List<MeasurementType>>
  _measurementTypesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.measurementTypes,
    aliasName: 'profiles__id__measurement_types__profile_id',
  );

  $$MeasurementTypesTableProcessedTableManager get measurementTypesRefs {
    final manager = $$MeasurementTypesTableTableManager(
      $_db,
      $_db.measurementTypes,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementTypesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MeasurementRecordsTable, List<MeasurementRecord>>
  _measurementRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementRecords,
        aliasName: 'profiles__id__measurement_records__profile_id',
      );

  $$MeasurementRecordsTableProcessedTableManager get measurementRecordsRefs {
    final manager = $$MeasurementRecordsTableTableManager(
      $_db,
      $_db.measurementRecords,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MeasurementSchedulesTable,
    List<MeasurementSchedule>
  >
  _measurementSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementSchedules,
        aliasName: 'profiles__id__measurement_schedules__profile_id',
      );

  $$MeasurementSchedulesTableProcessedTableManager
  get measurementSchedulesRefs {
    final manager = $$MeasurementSchedulesTableTableManager(
      $_db,
      $_db.measurementSchedules,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseTypesTable, List<ExerciseType>>
  _exerciseTypesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseTypes,
    aliasName: 'profiles__id__exercise_types__profile_id',
  );

  $$ExerciseTypesTableProcessedTableManager get exerciseTypesRefs {
    final manager = $$ExerciseTypesTableTableManager(
      $_db,
      $_db.exerciseTypes,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseTypesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseGoalsTable, List<ExerciseGoal>>
  _exerciseGoalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseGoals,
    aliasName: 'profiles__id__exercise_goals__profile_id',
  );

  $$ExerciseGoalsTableProcessedTableManager get exerciseGoalsRefs {
    final manager = $$ExerciseGoalsTableTableManager(
      $_db,
      $_db.exerciseGoals,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseGoalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseLogsTable, List<ExerciseLog>>
  _exerciseLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseLogs,
    aliasName: 'profiles__id__exercise_logs__profile_id',
  );

  $$ExerciseLogsTableProcessedTableManager get exerciseLogsRefs {
    final manager = $$ExerciseLogsTableTableManager(
      $_db,
      $_db.exerciseLogs,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DoctorsTable, List<Doctor>> _doctorsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.doctors,
    aliasName: 'profiles__id__doctors__profile_id',
  );

  $$DoctorsTableProcessedTableManager get doctorsRefs {
    final manager = $$DoctorsTableTableManager(
      $_db,
      $_db.doctors,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_doctorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DoctorVisitsTable, List<DoctorVisit>>
  _doctorVisitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.doctorVisits,
    aliasName: 'profiles__id__doctor_visits__profile_id',
  );

  $$DoctorVisitsTableProcessedTableManager get doctorVisitsRefs {
    final manager = $$DoctorVisitsTableTableManager(
      $_db,
      $_db.doctorVisits,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_doctorVisitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DocumentAttachmentsTable,
    List<DocumentAttachment>
  >
  _documentAttachmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.documentAttachments,
        aliasName: 'profiles__id__document_attachments__profile_id',
      );

  $$DocumentAttachmentsTableProcessedTableManager get documentAttachmentsRefs {
    final manager = $$DocumentAttachmentsTableTableManager(
      $_db,
      $_db.documentAttachments,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _documentAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DietPlansTable, List<DietPlan>>
  _dietPlansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dietPlans,
    aliasName: 'profiles__id__diet_plans__profile_id',
  );

  $$DietPlansTableProcessedTableManager get dietPlansRefs {
    final manager = $$DietPlansTableTableManager(
      $_db,
      $_db.dietPlans,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dietPlansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bloodType => $composableBuilder(
    column: $table.bloodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emergencyContactName => $composableBuilder(
    column: $table.emergencyContactName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emergencyContactPhone => $composableBuilder(
    column: $table.emergencyContactPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  Expression<bool> medicationsRefs(
    Expression<bool> Function($$MedicationsTableFilterComposer f) f,
  ) {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> measurementTypesRefs(
    Expression<bool> Function($$MeasurementTypesTableFilterComposer f) f,
  ) {
    final $$MeasurementTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementTypes,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTypesTableFilterComposer(
            $db: $db,
            $table: $db.measurementTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> measurementRecordsRefs(
    Expression<bool> Function($$MeasurementRecordsTableFilterComposer f) f,
  ) {
    final $$MeasurementRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementRecords,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementRecordsTableFilterComposer(
            $db: $db,
            $table: $db.measurementRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> measurementSchedulesRefs(
    Expression<bool> Function($$MeasurementSchedulesTableFilterComposer f) f,
  ) {
    final $$MeasurementSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementSchedules,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.measurementSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseTypesRefs(
    Expression<bool> Function($$ExerciseTypesTableFilterComposer f) f,
  ) {
    final $$ExerciseTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseTypes,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTypesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseGoalsRefs(
    Expression<bool> Function($$ExerciseGoalsTableFilterComposer f) f,
  ) {
    final $$ExerciseGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseGoals,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseGoalsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseLogsRefs(
    Expression<bool> Function($$ExerciseLogsTableFilterComposer f) f,
  ) {
    final $$ExerciseLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> doctorsRefs(
    Expression<bool> Function($$DoctorsTableFilterComposer f) f,
  ) {
    final $$DoctorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doctors,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorsTableFilterComposer(
            $db: $db,
            $table: $db.doctors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> doctorVisitsRefs(
    Expression<bool> Function($$DoctorVisitsTableFilterComposer f) f,
  ) {
    final $$DoctorVisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doctorVisits,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorVisitsTableFilterComposer(
            $db: $db,
            $table: $db.doctorVisits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentAttachmentsRefs(
    Expression<bool> Function($$DocumentAttachmentsTableFilterComposer f) f,
  ) {
    final $$DocumentAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentAttachments,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.documentAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dietPlansRefs(
    Expression<bool> Function($$DietPlansTableFilterComposer f) f,
  ) {
    final $$DietPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dietPlans,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DietPlansTableFilterComposer(
            $db: $db,
            $table: $db.dietPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bloodType => $composableBuilder(
    column: $table.bloodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emergencyContactName => $composableBuilder(
    column: $table.emergencyContactName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emergencyContactPhone => $composableBuilder(
    column: $table.emergencyContactPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get bloodType =>
      $composableBuilder(column: $table.bloodType, builder: (column) => column);

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<String> get emergencyContactName => $composableBuilder(
    column: $table.emergencyContactName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emergencyContactPhone => $composableBuilder(
    column: $table.emergencyContactPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> medicationsRefs<T extends Object>(
    Expression<T> Function($$MedicationsTableAnnotationComposer a) f,
  ) {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> measurementTypesRefs<T extends Object>(
    Expression<T> Function($$MeasurementTypesTableAnnotationComposer a) f,
  ) {
    final $$MeasurementTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementTypes,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.measurementTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> measurementRecordsRefs<T extends Object>(
    Expression<T> Function($$MeasurementRecordsTableAnnotationComposer a) f,
  ) {
    final $$MeasurementRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementRecords,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> measurementSchedulesRefs<T extends Object>(
    Expression<T> Function($$MeasurementSchedulesTableAnnotationComposer a) f,
  ) {
    final $$MeasurementSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementSchedules,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> exerciseTypesRefs<T extends Object>(
    Expression<T> Function($$ExerciseTypesTableAnnotationComposer a) f,
  ) {
    final $$ExerciseTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseTypes,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseGoalsRefs<T extends Object>(
    Expression<T> Function($$ExerciseGoalsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseGoals,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseGoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseLogsRefs<T extends Object>(
    Expression<T> Function($$ExerciseLogsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> doctorsRefs<T extends Object>(
    Expression<T> Function($$DoctorsTableAnnotationComposer a) f,
  ) {
    final $$DoctorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doctors,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorsTableAnnotationComposer(
            $db: $db,
            $table: $db.doctors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> doctorVisitsRefs<T extends Object>(
    Expression<T> Function($$DoctorVisitsTableAnnotationComposer a) f,
  ) {
    final $$DoctorVisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doctorVisits,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorVisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.doctorVisits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentAttachmentsRefs<T extends Object>(
    Expression<T> Function($$DocumentAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.documentAttachments,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DocumentAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.documentAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> dietPlansRefs<T extends Object>(
    Expression<T> Function($$DietPlansTableAnnotationComposer a) f,
  ) {
    final $$DietPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dietPlans,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DietPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.dietPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({
            bool medicationsRefs,
            bool measurementTypesRefs,
            bool measurementRecordsRefs,
            bool measurementSchedulesRefs,
            bool exerciseTypesRefs,
            bool exerciseGoalsRefs,
            bool exerciseLogsRefs,
            bool doctorsRefs,
            bool doctorVisitsRefs,
            bool documentAttachmentsRefs,
            bool dietPlansRefs,
          })
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> bloodType = const Value.absent(),
                Value<String?> allergies = const Value.absent(),
                Value<String?> emergencyContactName = const Value.absent(),
                Value<String?> emergencyContactPhone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                firstName: firstName,
                lastName: lastName,
                birthDate: birthDate,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                bloodType: bloodType,
                allergies: allergies,
                emergencyContactName: emergencyContactName,
                emergencyContactPhone: emergencyContactPhone,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String firstName,
                required String lastName,
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> bloodType = const Value.absent(),
                Value<String?> allergies = const Value.absent(),
                Value<String?> emergencyContactName = const Value.absent(),
                Value<String?> emergencyContactPhone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ProfilesCompanion.insert(
                id: id,
                firstName: firstName,
                lastName: lastName,
                birthDate: birthDate,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                bloodType: bloodType,
                allergies: allergies,
                emergencyContactName: emergencyContactName,
                emergencyContactPhone: emergencyContactPhone,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                medicationsRefs = false,
                measurementTypesRefs = false,
                measurementRecordsRefs = false,
                measurementSchedulesRefs = false,
                exerciseTypesRefs = false,
                exerciseGoalsRefs = false,
                exerciseLogsRefs = false,
                doctorsRefs = false,
                doctorVisitsRefs = false,
                documentAttachmentsRefs = false,
                dietPlansRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (medicationsRefs) db.medications,
                    if (measurementTypesRefs) db.measurementTypes,
                    if (measurementRecordsRefs) db.measurementRecords,
                    if (measurementSchedulesRefs) db.measurementSchedules,
                    if (exerciseTypesRefs) db.exerciseTypes,
                    if (exerciseGoalsRefs) db.exerciseGoals,
                    if (exerciseLogsRefs) db.exerciseLogs,
                    if (doctorsRefs) db.doctors,
                    if (doctorVisitsRefs) db.doctorVisits,
                    if (documentAttachmentsRefs) db.documentAttachments,
                    if (dietPlansRefs) db.dietPlans,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (medicationsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Medication
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._medicationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).medicationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (measurementTypesRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          MeasurementType
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._measurementTypesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).measurementTypesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (measurementRecordsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          MeasurementRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._measurementRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).measurementRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (measurementSchedulesRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          MeasurementSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._measurementSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).measurementSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseTypesRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          ExerciseType
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._exerciseTypesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseTypesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseGoalsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          ExerciseGoal
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._exerciseGoalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseGoalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseLogsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          ExerciseLog
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._exerciseLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (doctorsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Doctor
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._doctorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).doctorsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (doctorVisitsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          DoctorVisit
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._doctorVisitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).doctorVisitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (documentAttachmentsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          DocumentAttachment
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._documentAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).documentAttachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dietPlansRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          DietPlan
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._dietPlansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).dietPlansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({
        bool medicationsRefs,
        bool measurementTypesRefs,
        bool measurementRecordsRefs,
        bool measurementSchedulesRefs,
        bool exerciseTypesRefs,
        bool exerciseGoalsRefs,
        bool exerciseLogsRefs,
        bool doctorsRefs,
        bool doctorVisitsRefs,
        bool documentAttachmentsRefs,
        bool dietPlansRefs,
      })
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      required int profileId,
      required String name,
      Value<String?> description,
      Value<String?> doseAmount,
      Value<String?> doseUnit,
      Value<bool> active,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> name,
      Value<String?> description,
      Value<String?> doseAmount,
      Value<String?> doseUnit,
      Value<bool> active,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$MedicationsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationsTable, Medication> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('medications__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $MedicationSchedulesTable,
    List<MedicationSchedule>
  >
  _medicationSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.medicationSchedules,
        aliasName: 'medications__id__medication_schedules__medication_id',
      );

  $$MedicationSchedulesTableProcessedTableManager get medicationSchedulesRefs {
    final manager = $$MedicationSchedulesTableTableManager(
      $_db,
      $_db.medicationSchedules,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicationSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MedicationAlternativesTable,
    List<MedicationAlternative>
  >
  _medicationAlternativesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.medicationAlternatives,
        aliasName: 'medications__id__medication_alternatives__medication_id',
      );

  $$MedicationAlternativesTableProcessedTableManager
  get medicationAlternativesRefs {
    final manager = $$MedicationAlternativesTableTableManager(
      $_db,
      $_db.medicationAlternatives,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicationAlternativesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
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

  ColumnFilters<String> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> medicationSchedulesRefs(
    Expression<bool> Function($$MedicationSchedulesTableFilterComposer f) f,
  ) {
    final $$MedicationSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationSchedules,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.medicationSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> medicationAlternativesRefs(
    Expression<bool> Function($$MedicationAlternativesTableFilterComposer f) f,
  ) {
    final $$MedicationAlternativesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.medicationAlternatives,
          getReferencedColumn: (t) => t.medicationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MedicationAlternativesTableFilterComposer(
                $db: $db,
                $table: $db.medicationAlternatives,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
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

  ColumnOrderings<String> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doseUnit =>
      $composableBuilder(column: $table.doseUnit, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> medicationSchedulesRefs<T extends Object>(
    Expression<T> Function($$MedicationSchedulesTableAnnotationComposer a) f,
  ) {
    final $$MedicationSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.medicationSchedules,
          getReferencedColumn: (t) => t.medicationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MedicationSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.medicationSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> medicationAlternativesRefs<T extends Object>(
    Expression<T> Function($$MedicationAlternativesTableAnnotationComposer a) f,
  ) {
    final $$MedicationAlternativesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.medicationAlternatives,
          getReferencedColumn: (t) => t.medicationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MedicationAlternativesTableAnnotationComposer(
                $db: $db,
                $table: $db.medicationAlternatives,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (Medication, $$MedicationsTableReferences),
          Medication,
          PrefetchHooks Function({
            bool profileId,
            bool medicationSchedulesRefs,
            bool medicationAlternativesRefs,
          })
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> doseAmount = const Value.absent(),
                Value<String?> doseUnit = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                profileId: profileId,
                name: name,
                description: description,
                doseAmount: doseAmount,
                doseUnit: doseUnit,
                active: active,
                startDate: startDate,
                endDate: endDate,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> doseAmount = const Value.absent(),
                Value<String?> doseUnit = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => MedicationsCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                description: description,
                doseAmount: doseAmount,
                doseUnit: doseUnit,
                active: active,
                startDate: startDate,
                endDate: endDate,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                medicationSchedulesRefs = false,
                medicationAlternativesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (medicationSchedulesRefs) db.medicationSchedules,
                    if (medicationAlternativesRefs) db.medicationAlternatives,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$MedicationsTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$MedicationsTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (medicationSchedulesRefs)
                        await $_getPrefetchedData<
                          Medication,
                          $MedicationsTable,
                          MedicationSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._medicationSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).medicationSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (medicationAlternativesRefs)
                        await $_getPrefetchedData<
                          Medication,
                          $MedicationsTable,
                          MedicationAlternative
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._medicationAlternativesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).medicationAlternativesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (Medication, $$MedicationsTableReferences),
      Medication,
      PrefetchHooks Function({
        bool profileId,
        bool medicationSchedulesRefs,
        bool medicationAlternativesRefs,
      })
    >;
typedef $$MedicationSchedulesTableCreateCompanionBuilder =
    MedicationSchedulesCompanion Function({
      Value<int> id,
      required int medicationId,
      required String scheduleType,
      required String scheduleConfig,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> instructions,
      Value<bool> active,
    });
typedef $$MedicationSchedulesTableUpdateCompanionBuilder =
    MedicationSchedulesCompanion Function({
      Value<int> id,
      Value<int> medicationId,
      Value<String> scheduleType,
      Value<String> scheduleConfig,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> instructions,
      Value<bool> active,
    });

final class $$MedicationSchedulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MedicationSchedulesTable,
          MedicationSchedule
        > {
  $$MedicationSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) => db
      .medications
      .createAlias('medication_schedules__medication_id__medications__id');

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MedicationLogsTable, List<MedicationLog>>
  _medicationLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicationLogs,
    aliasName:
        'medication_schedules__id__medication_logs__medication_schedule_id',
  );

  $$MedicationLogsTableProcessedTableManager get medicationLogsRefs {
    final manager = $$MedicationLogsTableTableManager($_db, $_db.medicationLogs)
        .filter(
          (f) => f.medicationScheduleId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_medicationLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicationSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleConfig => $composableBuilder(
    column: $table.scheduleConfig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> medicationLogsRefs(
    Expression<bool> Function($$MedicationLogsTableFilterComposer f) f,
  ) {
    final $$MedicationLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationLogs,
      getReferencedColumn: (t) => t.medicationScheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationLogsTableFilterComposer(
            $db: $db,
            $table: $db.medicationLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleConfig => $composableBuilder(
    column: $table.scheduleConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleConfig => $composableBuilder(
    column: $table.scheduleConfig,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> medicationLogsRefs<T extends Object>(
    Expression<T> Function($$MedicationLogsTableAnnotationComposer a) f,
  ) {
    final $$MedicationLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationLogs,
      getReferencedColumn: (t) => t.medicationScheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.medicationLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationSchedulesTable,
          MedicationSchedule,
          $$MedicationSchedulesTableFilterComposer,
          $$MedicationSchedulesTableOrderingComposer,
          $$MedicationSchedulesTableAnnotationComposer,
          $$MedicationSchedulesTableCreateCompanionBuilder,
          $$MedicationSchedulesTableUpdateCompanionBuilder,
          (MedicationSchedule, $$MedicationSchedulesTableReferences),
          MedicationSchedule,
          PrefetchHooks Function({bool medicationId, bool medicationLogsRefs})
        > {
  $$MedicationSchedulesTableTableManager(
    _$AppDatabase db,
    $MedicationSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationSchedulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MedicationSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<String> scheduleConfig = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => MedicationSchedulesCompanion(
                id: id,
                medicationId: medicationId,
                scheduleType: scheduleType,
                scheduleConfig: scheduleConfig,
                startDate: startDate,
                endDate: endDate,
                instructions: instructions,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required String scheduleType,
                required String scheduleConfig,
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => MedicationSchedulesCompanion.insert(
                id: id,
                medicationId: medicationId,
                scheduleType: scheduleType,
                scheduleConfig: scheduleConfig,
                startDate: startDate,
                endDate: endDate,
                instructions: instructions,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({medicationId = false, medicationLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (medicationLogsRefs) db.medicationLogs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (medicationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.medicationId,
                                    referencedTable:
                                        $$MedicationSchedulesTableReferences
                                            ._medicationIdTable(db),
                                    referencedColumn:
                                        $$MedicationSchedulesTableReferences
                                            ._medicationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (medicationLogsRefs)
                        await $_getPrefetchedData<
                          MedicationSchedule,
                          $MedicationSchedulesTable,
                          MedicationLog
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationSchedulesTableReferences
                              ._medicationLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationSchedulesTableReferences(
                                db,
                                table,
                                p0,
                              ).medicationLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationScheduleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MedicationSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationSchedulesTable,
      MedicationSchedule,
      $$MedicationSchedulesTableFilterComposer,
      $$MedicationSchedulesTableOrderingComposer,
      $$MedicationSchedulesTableAnnotationComposer,
      $$MedicationSchedulesTableCreateCompanionBuilder,
      $$MedicationSchedulesTableUpdateCompanionBuilder,
      (MedicationSchedule, $$MedicationSchedulesTableReferences),
      MedicationSchedule,
      PrefetchHooks Function({bool medicationId, bool medicationLogsRefs})
    >;
typedef $$MedicationLogsTableCreateCompanionBuilder =
    MedicationLogsCompanion Function({
      Value<int> id,
      required int medicationScheduleId,
      required DateTime scheduledTime,
      Value<DateTime?> takenTime,
      required String status,
      Value<String?> notes,
      required DateTime createdAt,
    });
typedef $$MedicationLogsTableUpdateCompanionBuilder =
    MedicationLogsCompanion Function({
      Value<int> id,
      Value<int> medicationScheduleId,
      Value<DateTime> scheduledTime,
      Value<DateTime?> takenTime,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$MedicationLogsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationLogsTable, MedicationLog> {
  $$MedicationLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicationSchedulesTable _medicationScheduleIdTable(
    _$AppDatabase db,
  ) => db.medicationSchedules.createAlias(
    'medication_logs__medication_schedule_id__medication_schedules__id',
  );

  $$MedicationSchedulesTableProcessedTableManager get medicationScheduleId {
    final $_column = $_itemColumn<int>('medication_schedule_id')!;

    final manager = $$MedicationSchedulesTableTableManager(
      $_db,
      $_db.medicationSchedules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _medicationScheduleIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicationLogsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenTime => $composableBuilder(
    column: $table.takenTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationSchedulesTableFilterComposer get medicationScheduleId {
    final $$MedicationSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationScheduleId,
      referencedTable: $db.medicationSchedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.medicationSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenTime => $composableBuilder(
    column: $table.takenTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationSchedulesTableOrderingComposer get medicationScheduleId {
    final $$MedicationSchedulesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.medicationScheduleId,
          referencedTable: $db.medicationSchedules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MedicationSchedulesTableOrderingComposer(
                $db: $db,
                $table: $db.medicationSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MedicationLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationLogsTable> {
  $$MedicationLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get takenTime =>
      $composableBuilder(column: $table.takenTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicationSchedulesTableAnnotationComposer get medicationScheduleId {
    final $$MedicationSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.medicationScheduleId,
          referencedTable: $db.medicationSchedules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MedicationSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.medicationSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MedicationLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationLogsTable,
          MedicationLog,
          $$MedicationLogsTableFilterComposer,
          $$MedicationLogsTableOrderingComposer,
          $$MedicationLogsTableAnnotationComposer,
          $$MedicationLogsTableCreateCompanionBuilder,
          $$MedicationLogsTableUpdateCompanionBuilder,
          (MedicationLog, $$MedicationLogsTableReferences),
          MedicationLog,
          PrefetchHooks Function({bool medicationScheduleId})
        > {
  $$MedicationLogsTableTableManager(
    _$AppDatabase db,
    $MedicationLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationScheduleId = const Value.absent(),
                Value<DateTime> scheduledTime = const Value.absent(),
                Value<DateTime?> takenTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MedicationLogsCompanion(
                id: id,
                medicationScheduleId: medicationScheduleId,
                scheduledTime: scheduledTime,
                takenTime: takenTime,
                status: status,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationScheduleId,
                required DateTime scheduledTime,
                Value<DateTime?> takenTime = const Value.absent(),
                required String status,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
              }) => MedicationLogsCompanion.insert(
                id: id,
                medicationScheduleId: medicationScheduleId,
                scheduledTime: scheduledTime,
                takenTime: takenTime,
                status: status,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationScheduleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (medicationScheduleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicationScheduleId,
                                referencedTable: $$MedicationLogsTableReferences
                                    ._medicationScheduleIdTable(db),
                                referencedColumn:
                                    $$MedicationLogsTableReferences
                                        ._medicationScheduleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MedicationLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationLogsTable,
      MedicationLog,
      $$MedicationLogsTableFilterComposer,
      $$MedicationLogsTableOrderingComposer,
      $$MedicationLogsTableAnnotationComposer,
      $$MedicationLogsTableCreateCompanionBuilder,
      $$MedicationLogsTableUpdateCompanionBuilder,
      (MedicationLog, $$MedicationLogsTableReferences),
      MedicationLog,
      PrefetchHooks Function({bool medicationScheduleId})
    >;
typedef $$MedicationAlternativesTableCreateCompanionBuilder =
    MedicationAlternativesCompanion Function({
      Value<int> id,
      required int medicationId,
      required String name,
      Value<String?> doseAmount,
      Value<String?> doseUnit,
      Value<bool> doctorApproved,
      Value<String?> notes,
      required DateTime createdAt,
    });
typedef $$MedicationAlternativesTableUpdateCompanionBuilder =
    MedicationAlternativesCompanion Function({
      Value<int> id,
      Value<int> medicationId,
      Value<String> name,
      Value<String?> doseAmount,
      Value<String?> doseUnit,
      Value<bool> doctorApproved,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$MedicationAlternativesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MedicationAlternativesTable,
          MedicationAlternative
        > {
  $$MedicationAlternativesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) => db
      .medications
      .createAlias('medication_alternatives__medication_id__medications__id');

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicationAlternativesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationAlternativesTable> {
  $$MedicationAlternativesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get doctorApproved => $composableBuilder(
    column: $table.doctorApproved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationAlternativesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationAlternativesTable> {
  $$MedicationAlternativesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get doctorApproved => $composableBuilder(
    column: $table.doctorApproved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationAlternativesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationAlternativesTable> {
  $$MedicationAlternativesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doseUnit =>
      $composableBuilder(column: $table.doseUnit, builder: (column) => column);

  GeneratedColumn<bool> get doctorApproved => $composableBuilder(
    column: $table.doctorApproved,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationAlternativesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationAlternativesTable,
          MedicationAlternative,
          $$MedicationAlternativesTableFilterComposer,
          $$MedicationAlternativesTableOrderingComposer,
          $$MedicationAlternativesTableAnnotationComposer,
          $$MedicationAlternativesTableCreateCompanionBuilder,
          $$MedicationAlternativesTableUpdateCompanionBuilder,
          (MedicationAlternative, $$MedicationAlternativesTableReferences),
          MedicationAlternative,
          PrefetchHooks Function({bool medicationId})
        > {
  $$MedicationAlternativesTableTableManager(
    _$AppDatabase db,
    $MedicationAlternativesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationAlternativesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MedicationAlternativesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MedicationAlternativesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> doseAmount = const Value.absent(),
                Value<String?> doseUnit = const Value.absent(),
                Value<bool> doctorApproved = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MedicationAlternativesCompanion(
                id: id,
                medicationId: medicationId,
                name: name,
                doseAmount: doseAmount,
                doseUnit: doseUnit,
                doctorApproved: doctorApproved,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required String name,
                Value<String?> doseAmount = const Value.absent(),
                Value<String?> doseUnit = const Value.absent(),
                Value<bool> doctorApproved = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
              }) => MedicationAlternativesCompanion.insert(
                id: id,
                medicationId: medicationId,
                name: name,
                doseAmount: doseAmount,
                doseUnit: doseUnit,
                doctorApproved: doctorApproved,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationAlternativesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (medicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicationId,
                                referencedTable:
                                    $$MedicationAlternativesTableReferences
                                        ._medicationIdTable(db),
                                referencedColumn:
                                    $$MedicationAlternativesTableReferences
                                        ._medicationIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MedicationAlternativesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationAlternativesTable,
      MedicationAlternative,
      $$MedicationAlternativesTableFilterComposer,
      $$MedicationAlternativesTableOrderingComposer,
      $$MedicationAlternativesTableAnnotationComposer,
      $$MedicationAlternativesTableCreateCompanionBuilder,
      $$MedicationAlternativesTableUpdateCompanionBuilder,
      (MedicationAlternative, $$MedicationAlternativesTableReferences),
      MedicationAlternative,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$MeasurementTypesTableCreateCompanionBuilder =
    MeasurementTypesCompanion Function({
      Value<int> id,
      Value<int?> profileId,
      required String name,
      required String unit,
      required String measurementCategory,
      Value<bool> isSystem,
      Value<bool> active,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$MeasurementTypesTableUpdateCompanionBuilder =
    MeasurementTypesCompanion Function({
      Value<int> id,
      Value<int?> profileId,
      Value<String> name,
      Value<String> unit,
      Value<String> measurementCategory,
      Value<bool> isSystem,
      Value<bool> active,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$MeasurementTypesTableReferences
    extends
        BaseReferences<_$AppDatabase, $MeasurementTypesTable, MeasurementType> {
  $$MeasurementTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('measurement_types__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MeasurementRecordsTable, List<MeasurementRecord>>
  _measurementRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementRecords,
        aliasName:
            'measurement_types__id__measurement_records__measurement_type_id',
      );

  $$MeasurementRecordsTableProcessedTableManager get measurementRecordsRefs {
    final manager = $$MeasurementRecordsTableTableManager(
      $_db,
      $_db.measurementRecords,
    ).filter((f) => f.measurementTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MeasurementSchedulesTable,
    List<MeasurementSchedule>
  >
  _measurementSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementSchedules,
        aliasName:
            'measurement_types__id__measurement_schedules__measurement_type_id',
      );

  $$MeasurementSchedulesTableProcessedTableManager
  get measurementSchedulesRefs {
    final manager = $$MeasurementSchedulesTableTableManager(
      $_db,
      $_db.measurementSchedules,
    ).filter((f) => f.measurementTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MeasurementTypesTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementTypesTable> {
  $$MeasurementTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measurementCategory => $composableBuilder(
    column: $table.measurementCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
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

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> measurementRecordsRefs(
    Expression<bool> Function($$MeasurementRecordsTableFilterComposer f) f,
  ) {
    final $$MeasurementRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementRecords,
      getReferencedColumn: (t) => t.measurementTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementRecordsTableFilterComposer(
            $db: $db,
            $table: $db.measurementRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> measurementSchedulesRefs(
    Expression<bool> Function($$MeasurementSchedulesTableFilterComposer f) f,
  ) {
    final $$MeasurementSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementSchedules,
      getReferencedColumn: (t) => t.measurementTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.measurementSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeasurementTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementTypesTable> {
  $$MeasurementTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measurementCategory => $composableBuilder(
    column: $table.measurementCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
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

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementTypesTable> {
  $$MeasurementTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get measurementCategory => $composableBuilder(
    column: $table.measurementCategory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> measurementRecordsRefs<T extends Object>(
    Expression<T> Function($$MeasurementRecordsTableAnnotationComposer a) f,
  ) {
    final $$MeasurementRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementRecords,
          getReferencedColumn: (t) => t.measurementTypeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> measurementSchedulesRefs<T extends Object>(
    Expression<T> Function($$MeasurementSchedulesTableAnnotationComposer a) f,
  ) {
    final $$MeasurementSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementSchedules,
          getReferencedColumn: (t) => t.measurementTypeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MeasurementTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementTypesTable,
          MeasurementType,
          $$MeasurementTypesTableFilterComposer,
          $$MeasurementTypesTableOrderingComposer,
          $$MeasurementTypesTableAnnotationComposer,
          $$MeasurementTypesTableCreateCompanionBuilder,
          $$MeasurementTypesTableUpdateCompanionBuilder,
          (MeasurementType, $$MeasurementTypesTableReferences),
          MeasurementType,
          PrefetchHooks Function({
            bool profileId,
            bool measurementRecordsRefs,
            bool measurementSchedulesRefs,
          })
        > {
  $$MeasurementTypesTableTableManager(
    _$AppDatabase db,
    $MeasurementTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> measurementCategory = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MeasurementTypesCompanion(
                id: id,
                profileId: profileId,
                name: name,
                unit: unit,
                measurementCategory: measurementCategory,
                isSystem: isSystem,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                required String name,
                required String unit,
                required String measurementCategory,
                Value<bool> isSystem = const Value.absent(),
                Value<bool> active = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => MeasurementTypesCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                unit: unit,
                measurementCategory: measurementCategory,
                isSystem: isSystem,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MeasurementTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                measurementRecordsRefs = false,
                measurementSchedulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (measurementRecordsRefs) db.measurementRecords,
                    if (measurementSchedulesRefs) db.measurementSchedules,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$MeasurementTypesTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$MeasurementTypesTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (measurementRecordsRefs)
                        await $_getPrefetchedData<
                          MeasurementType,
                          $MeasurementTypesTable,
                          MeasurementRecord
                        >(
                          currentTable: table,
                          referencedTable: $$MeasurementTypesTableReferences
                              ._measurementRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MeasurementTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).measurementRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.measurementTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (measurementSchedulesRefs)
                        await $_getPrefetchedData<
                          MeasurementType,
                          $MeasurementTypesTable,
                          MeasurementSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$MeasurementTypesTableReferences
                              ._measurementSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MeasurementTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).measurementSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.measurementTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MeasurementTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementTypesTable,
      MeasurementType,
      $$MeasurementTypesTableFilterComposer,
      $$MeasurementTypesTableOrderingComposer,
      $$MeasurementTypesTableAnnotationComposer,
      $$MeasurementTypesTableCreateCompanionBuilder,
      $$MeasurementTypesTableUpdateCompanionBuilder,
      (MeasurementType, $$MeasurementTypesTableReferences),
      MeasurementType,
      PrefetchHooks Function({
        bool profileId,
        bool measurementRecordsRefs,
        bool measurementSchedulesRefs,
      })
    >;
typedef $$MeasurementRecordsTableCreateCompanionBuilder =
    MeasurementRecordsCompanion Function({
      Value<int> id,
      required int profileId,
      required int measurementTypeId,
      required DateTime timestamp,
      required double valuePrimary,
      Value<double?> valueSecondary,
      Value<double?> valueTertiary,
      required String unit,
      Value<String?> notes,
      required DateTime createdAt,
    });
typedef $$MeasurementRecordsTableUpdateCompanionBuilder =
    MeasurementRecordsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<int> measurementTypeId,
      Value<DateTime> timestamp,
      Value<double> valuePrimary,
      Value<double?> valueSecondary,
      Value<double?> valueTertiary,
      Value<String> unit,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$MeasurementRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MeasurementRecordsTable,
          MeasurementRecord
        > {
  $$MeasurementRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('measurement_records__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MeasurementTypesTable _measurementTypeIdTable(_$AppDatabase db) =>
      db.measurementTypes.createAlias(
        'measurement_records__measurement_type_id__measurement_types__id',
      );

  $$MeasurementTypesTableProcessedTableManager get measurementTypeId {
    final $_column = $_itemColumn<int>('measurement_type_id')!;

    final manager = $$MeasurementTypesTableTableManager(
      $_db,
      $_db.measurementTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_measurementTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeasurementRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementRecordsTable> {
  $$MeasurementRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valuePrimary => $composableBuilder(
    column: $table.valuePrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueSecondary => $composableBuilder(
    column: $table.valueSecondary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueTertiary => $composableBuilder(
    column: $table.valueTertiary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MeasurementTypesTableFilterComposer get measurementTypeId {
    final $$MeasurementTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementTypeId,
      referencedTable: $db.measurementTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTypesTableFilterComposer(
            $db: $db,
            $table: $db.measurementTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementRecordsTable> {
  $$MeasurementRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valuePrimary => $composableBuilder(
    column: $table.valuePrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueSecondary => $composableBuilder(
    column: $table.valueSecondary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueTertiary => $composableBuilder(
    column: $table.valueTertiary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MeasurementTypesTableOrderingComposer get measurementTypeId {
    final $$MeasurementTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementTypeId,
      referencedTable: $db.measurementTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTypesTableOrderingComposer(
            $db: $db,
            $table: $db.measurementTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementRecordsTable> {
  $$MeasurementRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get valuePrimary => $composableBuilder(
    column: $table.valuePrimary,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valueSecondary => $composableBuilder(
    column: $table.valueSecondary,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valueTertiary => $composableBuilder(
    column: $table.valueTertiary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MeasurementTypesTableAnnotationComposer get measurementTypeId {
    final $$MeasurementTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementTypeId,
      referencedTable: $db.measurementTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.measurementTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementRecordsTable,
          MeasurementRecord,
          $$MeasurementRecordsTableFilterComposer,
          $$MeasurementRecordsTableOrderingComposer,
          $$MeasurementRecordsTableAnnotationComposer,
          $$MeasurementRecordsTableCreateCompanionBuilder,
          $$MeasurementRecordsTableUpdateCompanionBuilder,
          (MeasurementRecord, $$MeasurementRecordsTableReferences),
          MeasurementRecord,
          PrefetchHooks Function({bool profileId, bool measurementTypeId})
        > {
  $$MeasurementRecordsTableTableManager(
    _$AppDatabase db,
    $MeasurementRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<int> measurementTypeId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double> valuePrimary = const Value.absent(),
                Value<double?> valueSecondary = const Value.absent(),
                Value<double?> valueTertiary = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MeasurementRecordsCompanion(
                id: id,
                profileId: profileId,
                measurementTypeId: measurementTypeId,
                timestamp: timestamp,
                valuePrimary: valuePrimary,
                valueSecondary: valueSecondary,
                valueTertiary: valueTertiary,
                unit: unit,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required int measurementTypeId,
                required DateTime timestamp,
                required double valuePrimary,
                Value<double?> valueSecondary = const Value.absent(),
                Value<double?> valueTertiary = const Value.absent(),
                required String unit,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
              }) => MeasurementRecordsCompanion.insert(
                id: id,
                profileId: profileId,
                measurementTypeId: measurementTypeId,
                timestamp: timestamp,
                valuePrimary: valuePrimary,
                valueSecondary: valueSecondary,
                valueTertiary: valueTertiary,
                unit: unit,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MeasurementRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, measurementTypeId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$MeasurementRecordsTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$MeasurementRecordsTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (measurementTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.measurementTypeId,
                                    referencedTable:
                                        $$MeasurementRecordsTableReferences
                                            ._measurementTypeIdTable(db),
                                    referencedColumn:
                                        $$MeasurementRecordsTableReferences
                                            ._measurementTypeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$MeasurementRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementRecordsTable,
      MeasurementRecord,
      $$MeasurementRecordsTableFilterComposer,
      $$MeasurementRecordsTableOrderingComposer,
      $$MeasurementRecordsTableAnnotationComposer,
      $$MeasurementRecordsTableCreateCompanionBuilder,
      $$MeasurementRecordsTableUpdateCompanionBuilder,
      (MeasurementRecord, $$MeasurementRecordsTableReferences),
      MeasurementRecord,
      PrefetchHooks Function({bool profileId, bool measurementTypeId})
    >;
typedef $$MeasurementSchedulesTableCreateCompanionBuilder =
    MeasurementSchedulesCompanion Function({
      Value<int> id,
      required int profileId,
      required int measurementTypeId,
      required String scheduleConfig,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<bool> active,
    });
typedef $$MeasurementSchedulesTableUpdateCompanionBuilder =
    MeasurementSchedulesCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<int> measurementTypeId,
      Value<String> scheduleConfig,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<bool> active,
    });

final class $$MeasurementSchedulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MeasurementSchedulesTable,
          MeasurementSchedule
        > {
  $$MeasurementSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) => db.profiles
      .createAlias('measurement_schedules__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MeasurementTypesTable _measurementTypeIdTable(_$AppDatabase db) =>
      db.measurementTypes.createAlias(
        'measurement_schedules__measurement_type_id__measurement_types__id',
      );

  $$MeasurementTypesTableProcessedTableManager get measurementTypeId {
    final $_column = $_itemColumn<int>('measurement_type_id')!;

    final manager = $$MeasurementTypesTableTableManager(
      $_db,
      $_db.measurementTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_measurementTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeasurementSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementSchedulesTable> {
  $$MeasurementSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleConfig => $composableBuilder(
    column: $table.scheduleConfig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MeasurementTypesTableFilterComposer get measurementTypeId {
    final $$MeasurementTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementTypeId,
      referencedTable: $db.measurementTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTypesTableFilterComposer(
            $db: $db,
            $table: $db.measurementTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementSchedulesTable> {
  $$MeasurementSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleConfig => $composableBuilder(
    column: $table.scheduleConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MeasurementTypesTableOrderingComposer get measurementTypeId {
    final $$MeasurementTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementTypeId,
      referencedTable: $db.measurementTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTypesTableOrderingComposer(
            $db: $db,
            $table: $db.measurementTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementSchedulesTable> {
  $$MeasurementSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scheduleConfig => $composableBuilder(
    column: $table.scheduleConfig,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MeasurementTypesTableAnnotationComposer get measurementTypeId {
    final $$MeasurementTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementTypeId,
      referencedTable: $db.measurementTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.measurementTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementSchedulesTable,
          MeasurementSchedule,
          $$MeasurementSchedulesTableFilterComposer,
          $$MeasurementSchedulesTableOrderingComposer,
          $$MeasurementSchedulesTableAnnotationComposer,
          $$MeasurementSchedulesTableCreateCompanionBuilder,
          $$MeasurementSchedulesTableUpdateCompanionBuilder,
          (MeasurementSchedule, $$MeasurementSchedulesTableReferences),
          MeasurementSchedule,
          PrefetchHooks Function({bool profileId, bool measurementTypeId})
        > {
  $$MeasurementSchedulesTableTableManager(
    _$AppDatabase db,
    $MeasurementSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementSchedulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MeasurementSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<int> measurementTypeId = const Value.absent(),
                Value<String> scheduleConfig = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => MeasurementSchedulesCompanion(
                id: id,
                profileId: profileId,
                measurementTypeId: measurementTypeId,
                scheduleConfig: scheduleConfig,
                startDate: startDate,
                endDate: endDate,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required int measurementTypeId,
                required String scheduleConfig,
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => MeasurementSchedulesCompanion.insert(
                id: id,
                profileId: profileId,
                measurementTypeId: measurementTypeId,
                scheduleConfig: scheduleConfig,
                startDate: startDate,
                endDate: endDate,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MeasurementSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, measurementTypeId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$MeasurementSchedulesTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$MeasurementSchedulesTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (measurementTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.measurementTypeId,
                                    referencedTable:
                                        $$MeasurementSchedulesTableReferences
                                            ._measurementTypeIdTable(db),
                                    referencedColumn:
                                        $$MeasurementSchedulesTableReferences
                                            ._measurementTypeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$MeasurementSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementSchedulesTable,
      MeasurementSchedule,
      $$MeasurementSchedulesTableFilterComposer,
      $$MeasurementSchedulesTableOrderingComposer,
      $$MeasurementSchedulesTableAnnotationComposer,
      $$MeasurementSchedulesTableCreateCompanionBuilder,
      $$MeasurementSchedulesTableUpdateCompanionBuilder,
      (MeasurementSchedule, $$MeasurementSchedulesTableReferences),
      MeasurementSchedule,
      PrefetchHooks Function({bool profileId, bool measurementTypeId})
    >;
typedef $$ExerciseTypesTableCreateCompanionBuilder =
    ExerciseTypesCompanion Function({
      Value<int> id,
      required int profileId,
      required String name,
      required String unit,
      Value<String?> notes,
      Value<bool> active,
    });
typedef $$ExerciseTypesTableUpdateCompanionBuilder =
    ExerciseTypesCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> name,
      Value<String> unit,
      Value<String?> notes,
      Value<bool> active,
    });

final class $$ExerciseTypesTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseTypesTable, ExerciseType> {
  $$ExerciseTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('exercise_types__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExerciseGoalsTable, List<ExerciseGoal>>
  _exerciseGoalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseGoals,
    aliasName: 'exercise_types__id__exercise_goals__exercise_type_id',
  );

  $$ExerciseGoalsTableProcessedTableManager get exerciseGoalsRefs {
    final manager = $$ExerciseGoalsTableTableManager(
      $_db,
      $_db.exerciseGoals,
    ).filter((f) => f.exerciseTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseGoalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseLogsTable, List<ExerciseLog>>
  _exerciseLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseLogs,
    aliasName: 'exercise_types__id__exercise_logs__exercise_type_id',
  );

  $$ExerciseLogsTableProcessedTableManager get exerciseLogsRefs {
    final manager = $$ExerciseLogsTableTableManager(
      $_db,
      $_db.exerciseLogs,
    ).filter((f) => f.exerciseTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExerciseTypesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseTypesTable> {
  $$ExerciseTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseGoalsRefs(
    Expression<bool> Function($$ExerciseGoalsTableFilterComposer f) f,
  ) {
    final $$ExerciseGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseGoals,
      getReferencedColumn: (t) => t.exerciseTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseGoalsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseLogsRefs(
    Expression<bool> Function($$ExerciseLogsTableFilterComposer f) f,
  ) {
    final $$ExerciseLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.exerciseTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseTypesTable> {
  $$ExerciseTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseTypesTable> {
  $$ExerciseTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseGoalsRefs<T extends Object>(
    Expression<T> Function($$ExerciseGoalsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseGoals,
      getReferencedColumn: (t) => t.exerciseTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseGoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseLogsRefs<T extends Object>(
    Expression<T> Function($$ExerciseLogsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.exerciseTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseTypesTable,
          ExerciseType,
          $$ExerciseTypesTableFilterComposer,
          $$ExerciseTypesTableOrderingComposer,
          $$ExerciseTypesTableAnnotationComposer,
          $$ExerciseTypesTableCreateCompanionBuilder,
          $$ExerciseTypesTableUpdateCompanionBuilder,
          (ExerciseType, $$ExerciseTypesTableReferences),
          ExerciseType,
          PrefetchHooks Function({
            bool profileId,
            bool exerciseGoalsRefs,
            bool exerciseLogsRefs,
          })
        > {
  $$ExerciseTypesTableTableManager(_$AppDatabase db, $ExerciseTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => ExerciseTypesCompanion(
                id: id,
                profileId: profileId,
                name: name,
                unit: unit,
                notes: notes,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String name,
                required String unit,
                Value<String?> notes = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => ExerciseTypesCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                unit: unit,
                notes: notes,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                exerciseGoalsRefs = false,
                exerciseLogsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseGoalsRefs) db.exerciseGoals,
                    if (exerciseLogsRefs) db.exerciseLogs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$ExerciseTypesTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$ExerciseTypesTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseGoalsRefs)
                        await $_getPrefetchedData<
                          ExerciseType,
                          $ExerciseTypesTable,
                          ExerciseGoal
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseTypesTableReferences
                              ._exerciseGoalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExerciseTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseGoalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseLogsRefs)
                        await $_getPrefetchedData<
                          ExerciseType,
                          $ExerciseTypesTable,
                          ExerciseLog
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseTypesTableReferences
                              ._exerciseLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExerciseTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExerciseTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseTypesTable,
      ExerciseType,
      $$ExerciseTypesTableFilterComposer,
      $$ExerciseTypesTableOrderingComposer,
      $$ExerciseTypesTableAnnotationComposer,
      $$ExerciseTypesTableCreateCompanionBuilder,
      $$ExerciseTypesTableUpdateCompanionBuilder,
      (ExerciseType, $$ExerciseTypesTableReferences),
      ExerciseType,
      PrefetchHooks Function({
        bool profileId,
        bool exerciseGoalsRefs,
        bool exerciseLogsRefs,
      })
    >;
typedef $$ExerciseGoalsTableCreateCompanionBuilder =
    ExerciseGoalsCompanion Function({
      Value<int> id,
      required int profileId,
      required int exerciseTypeId,
      required double targetValue,
      required String targetUnit,
      Value<String?> frequency,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<bool> active,
    });
typedef $$ExerciseGoalsTableUpdateCompanionBuilder =
    ExerciseGoalsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<int> exerciseTypeId,
      Value<double> targetValue,
      Value<String> targetUnit,
      Value<String?> frequency,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<bool> active,
    });

final class $$ExerciseGoalsTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseGoalsTable, ExerciseGoal> {
  $$ExerciseGoalsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('exercise_goals__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciseTypesTable _exerciseTypeIdTable(_$AppDatabase db) => db
      .exerciseTypes
      .createAlias('exercise_goals__exercise_type_id__exercise_types__id');

  $$ExerciseTypesTableProcessedTableManager get exerciseTypeId {
    final $_column = $_itemColumn<int>('exercise_type_id')!;

    final manager = $$ExerciseTypesTableTableManager(
      $_db,
      $_db.exerciseTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseGoalsTable> {
  $$ExerciseGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetUnit => $composableBuilder(
    column: $table.targetUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTypesTableFilterComposer get exerciseTypeId {
    final $$ExerciseTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseTypeId,
      referencedTable: $db.exerciseTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTypesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseGoalsTable> {
  $$ExerciseGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetUnit => $composableBuilder(
    column: $table.targetUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTypesTableOrderingComposer get exerciseTypeId {
    final $$ExerciseTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseTypeId,
      referencedTable: $db.exerciseTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTypesTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseGoalsTable> {
  $$ExerciseGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetUnit => $composableBuilder(
    column: $table.targetUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTypesTableAnnotationComposer get exerciseTypeId {
    final $$ExerciseTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseTypeId,
      referencedTable: $db.exerciseTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseGoalsTable,
          ExerciseGoal,
          $$ExerciseGoalsTableFilterComposer,
          $$ExerciseGoalsTableOrderingComposer,
          $$ExerciseGoalsTableAnnotationComposer,
          $$ExerciseGoalsTableCreateCompanionBuilder,
          $$ExerciseGoalsTableUpdateCompanionBuilder,
          (ExerciseGoal, $$ExerciseGoalsTableReferences),
          ExerciseGoal,
          PrefetchHooks Function({bool profileId, bool exerciseTypeId})
        > {
  $$ExerciseGoalsTableTableManager(_$AppDatabase db, $ExerciseGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<int> exerciseTypeId = const Value.absent(),
                Value<double> targetValue = const Value.absent(),
                Value<String> targetUnit = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => ExerciseGoalsCompanion(
                id: id,
                profileId: profileId,
                exerciseTypeId: exerciseTypeId,
                targetValue: targetValue,
                targetUnit: targetUnit,
                frequency: frequency,
                startDate: startDate,
                endDate: endDate,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required int exerciseTypeId,
                required double targetValue,
                required String targetUnit,
                Value<String?> frequency = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => ExerciseGoalsCompanion.insert(
                id: id,
                profileId: profileId,
                exerciseTypeId: exerciseTypeId,
                targetValue: targetValue,
                targetUnit: targetUnit,
                frequency: frequency,
                startDate: startDate,
                endDate: endDate,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseGoalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, exerciseTypeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$ExerciseGoalsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$ExerciseGoalsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (exerciseTypeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseTypeId,
                                referencedTable: $$ExerciseGoalsTableReferences
                                    ._exerciseTypeIdTable(db),
                                referencedColumn: $$ExerciseGoalsTableReferences
                                    ._exerciseTypeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseGoalsTable,
      ExerciseGoal,
      $$ExerciseGoalsTableFilterComposer,
      $$ExerciseGoalsTableOrderingComposer,
      $$ExerciseGoalsTableAnnotationComposer,
      $$ExerciseGoalsTableCreateCompanionBuilder,
      $$ExerciseGoalsTableUpdateCompanionBuilder,
      (ExerciseGoal, $$ExerciseGoalsTableReferences),
      ExerciseGoal,
      PrefetchHooks Function({bool profileId, bool exerciseTypeId})
    >;
typedef $$ExerciseLogsTableCreateCompanionBuilder =
    ExerciseLogsCompanion Function({
      Value<int> id,
      required int profileId,
      required int exerciseTypeId,
      required DateTime logDate,
      Value<int?> durationMinutes,
      Value<double?> distance,
      Value<int?> calories,
      Value<String?> notes,
    });
typedef $$ExerciseLogsTableUpdateCompanionBuilder =
    ExerciseLogsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<int> exerciseTypeId,
      Value<DateTime> logDate,
      Value<int?> durationMinutes,
      Value<double?> distance,
      Value<int?> calories,
      Value<String?> notes,
    });

final class $$ExerciseLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseLogsTable, ExerciseLog> {
  $$ExerciseLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('exercise_logs__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciseTypesTable _exerciseTypeIdTable(_$AppDatabase db) => db
      .exerciseTypes
      .createAlias('exercise_logs__exercise_type_id__exercise_types__id');

  $$ExerciseTypesTableProcessedTableManager get exerciseTypeId {
    final $_column = $_itemColumn<int>('exercise_type_id')!;

    final manager = $$ExerciseTypesTableTableManager(
      $_db,
      $_db.exerciseTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseLogsTable> {
  $$ExerciseLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTypesTableFilterComposer get exerciseTypeId {
    final $$ExerciseTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseTypeId,
      referencedTable: $db.exerciseTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTypesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseLogsTable> {
  $$ExerciseLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTypesTableOrderingComposer get exerciseTypeId {
    final $$ExerciseTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseTypeId,
      referencedTable: $db.exerciseTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTypesTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseLogsTable> {
  $$ExerciseLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTypesTableAnnotationComposer get exerciseTypeId {
    final $$ExerciseTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseTypeId,
      referencedTable: $db.exerciseTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseLogsTable,
          ExerciseLog,
          $$ExerciseLogsTableFilterComposer,
          $$ExerciseLogsTableOrderingComposer,
          $$ExerciseLogsTableAnnotationComposer,
          $$ExerciseLogsTableCreateCompanionBuilder,
          $$ExerciseLogsTableUpdateCompanionBuilder,
          (ExerciseLog, $$ExerciseLogsTableReferences),
          ExerciseLog,
          PrefetchHooks Function({bool profileId, bool exerciseTypeId})
        > {
  $$ExerciseLogsTableTableManager(_$AppDatabase db, $ExerciseLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<int> exerciseTypeId = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<double?> distance = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ExerciseLogsCompanion(
                id: id,
                profileId: profileId,
                exerciseTypeId: exerciseTypeId,
                logDate: logDate,
                durationMinutes: durationMinutes,
                distance: distance,
                calories: calories,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required int exerciseTypeId,
                required DateTime logDate,
                Value<int?> durationMinutes = const Value.absent(),
                Value<double?> distance = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ExerciseLogsCompanion.insert(
                id: id,
                profileId: profileId,
                exerciseTypeId: exerciseTypeId,
                logDate: logDate,
                durationMinutes: durationMinutes,
                distance: distance,
                calories: calories,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, exerciseTypeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$ExerciseLogsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$ExerciseLogsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (exerciseTypeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseTypeId,
                                referencedTable: $$ExerciseLogsTableReferences
                                    ._exerciseTypeIdTable(db),
                                referencedColumn: $$ExerciseLogsTableReferences
                                    ._exerciseTypeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseLogsTable,
      ExerciseLog,
      $$ExerciseLogsTableFilterComposer,
      $$ExerciseLogsTableOrderingComposer,
      $$ExerciseLogsTableAnnotationComposer,
      $$ExerciseLogsTableCreateCompanionBuilder,
      $$ExerciseLogsTableUpdateCompanionBuilder,
      (ExerciseLog, $$ExerciseLogsTableReferences),
      ExerciseLog,
      PrefetchHooks Function({bool profileId, bool exerciseTypeId})
    >;
typedef $$DoctorsTableCreateCompanionBuilder =
    DoctorsCompanion Function({
      Value<int> id,
      required int profileId,
      required String firstName,
      required String lastName,
      Value<String?> specialty,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> clinic,
      Value<String?> notes,
    });
typedef $$DoctorsTableUpdateCompanionBuilder =
    DoctorsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> firstName,
      Value<String> lastName,
      Value<String?> specialty,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> clinic,
      Value<String?> notes,
    });

final class $$DoctorsTableReferences
    extends BaseReferences<_$AppDatabase, $DoctorsTable, Doctor> {
  $$DoctorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('doctors__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DoctorVisitsTable, List<DoctorVisit>>
  _doctorVisitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.doctorVisits,
    aliasName: 'doctors__id__doctor_visits__doctor_id',
  );

  $$DoctorVisitsTableProcessedTableManager get doctorVisitsRefs {
    final manager = $$DoctorVisitsTableTableManager(
      $_db,
      $_db.doctorVisits,
    ).filter((f) => f.doctorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_doctorVisitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DoctorsTableFilterComposer
    extends Composer<_$AppDatabase, $DoctorsTable> {
  $$DoctorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinic => $composableBuilder(
    column: $table.clinic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> doctorVisitsRefs(
    Expression<bool> Function($$DoctorVisitsTableFilterComposer f) f,
  ) {
    final $$DoctorVisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doctorVisits,
      getReferencedColumn: (t) => t.doctorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorVisitsTableFilterComposer(
            $db: $db,
            $table: $db.doctorVisits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DoctorsTableOrderingComposer
    extends Composer<_$AppDatabase, $DoctorsTable> {
  $$DoctorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinic => $composableBuilder(
    column: $table.clinic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoctorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoctorsTable> {
  $$DoctorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get specialty =>
      $composableBuilder(column: $table.specialty, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get clinic =>
      $composableBuilder(column: $table.clinic, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> doctorVisitsRefs<T extends Object>(
    Expression<T> Function($$DoctorVisitsTableAnnotationComposer a) f,
  ) {
    final $$DoctorVisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doctorVisits,
      getReferencedColumn: (t) => t.doctorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorVisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.doctorVisits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DoctorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DoctorsTable,
          Doctor,
          $$DoctorsTableFilterComposer,
          $$DoctorsTableOrderingComposer,
          $$DoctorsTableAnnotationComposer,
          $$DoctorsTableCreateCompanionBuilder,
          $$DoctorsTableUpdateCompanionBuilder,
          (Doctor, $$DoctorsTableReferences),
          Doctor,
          PrefetchHooks Function({bool profileId, bool doctorVisitsRefs})
        > {
  $$DoctorsTableTableManager(_$AppDatabase db, $DoctorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoctorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoctorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoctorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String?> specialty = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> clinic = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DoctorsCompanion(
                id: id,
                profileId: profileId,
                firstName: firstName,
                lastName: lastName,
                specialty: specialty,
                phone: phone,
                email: email,
                clinic: clinic,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String firstName,
                required String lastName,
                Value<String?> specialty = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> clinic = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DoctorsCompanion.insert(
                id: id,
                profileId: profileId,
                firstName: firstName,
                lastName: lastName,
                specialty: specialty,
                phone: phone,
                email: email,
                clinic: clinic,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DoctorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, doctorVisitsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (doctorVisitsRefs) db.doctorVisits,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable: $$DoctorsTableReferences
                                        ._profileIdTable(db),
                                    referencedColumn: $$DoctorsTableReferences
                                        ._profileIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (doctorVisitsRefs)
                        await $_getPrefetchedData<
                          Doctor,
                          $DoctorsTable,
                          DoctorVisit
                        >(
                          currentTable: table,
                          referencedTable: $$DoctorsTableReferences
                              ._doctorVisitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DoctorsTableReferences(
                                db,
                                table,
                                p0,
                              ).doctorVisitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.doctorId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DoctorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DoctorsTable,
      Doctor,
      $$DoctorsTableFilterComposer,
      $$DoctorsTableOrderingComposer,
      $$DoctorsTableAnnotationComposer,
      $$DoctorsTableCreateCompanionBuilder,
      $$DoctorsTableUpdateCompanionBuilder,
      (Doctor, $$DoctorsTableReferences),
      Doctor,
      PrefetchHooks Function({bool profileId, bool doctorVisitsRefs})
    >;
typedef $$DoctorVisitsTableCreateCompanionBuilder =
    DoctorVisitsCompanion Function({
      Value<int> id,
      required int profileId,
      required int doctorId,
      required DateTime visitDate,
      required String status,
      Value<String?> reason,
      Value<String?> notes,
      Value<bool> reminderEnabled,
      Value<int> reminderMinutesBefore,
    });
typedef $$DoctorVisitsTableUpdateCompanionBuilder =
    DoctorVisitsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<int> doctorId,
      Value<DateTime> visitDate,
      Value<String> status,
      Value<String?> reason,
      Value<String?> notes,
      Value<bool> reminderEnabled,
      Value<int> reminderMinutesBefore,
    });

final class $$DoctorVisitsTableReferences
    extends BaseReferences<_$AppDatabase, $DoctorVisitsTable, DoctorVisit> {
  $$DoctorVisitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('doctor_visits__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DoctorsTable _doctorIdTable(_$AppDatabase db) =>
      db.doctors.createAlias('doctor_visits__doctor_id__doctors__id');

  $$DoctorsTableProcessedTableManager get doctorId {
    final $_column = $_itemColumn<int>('doctor_id')!;

    final manager = $$DoctorsTableTableManager(
      $_db,
      $_db.doctors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_doctorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DoctorVisitsTableFilterComposer
    extends Composer<_$AppDatabase, $DoctorVisitsTable> {
  $$DoctorVisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinutesBefore => $composableBuilder(
    column: $table.reminderMinutesBefore,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DoctorsTableFilterComposer get doctorId {
    final $$DoctorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doctorId,
      referencedTable: $db.doctors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorsTableFilterComposer(
            $db: $db,
            $table: $db.doctors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoctorVisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $DoctorVisitsTable> {
  $$DoctorVisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinutesBefore => $composableBuilder(
    column: $table.reminderMinutesBefore,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DoctorsTableOrderingComposer get doctorId {
    final $$DoctorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doctorId,
      referencedTable: $db.doctors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorsTableOrderingComposer(
            $db: $db,
            $table: $db.doctors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoctorVisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoctorVisitsTable> {
  $$DoctorVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get visitDate =>
      $composableBuilder(column: $table.visitDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinutesBefore => $composableBuilder(
    column: $table.reminderMinutesBefore,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DoctorsTableAnnotationComposer get doctorId {
    final $$DoctorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.doctorId,
      referencedTable: $db.doctors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoctorsTableAnnotationComposer(
            $db: $db,
            $table: $db.doctors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoctorVisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DoctorVisitsTable,
          DoctorVisit,
          $$DoctorVisitsTableFilterComposer,
          $$DoctorVisitsTableOrderingComposer,
          $$DoctorVisitsTableAnnotationComposer,
          $$DoctorVisitsTableCreateCompanionBuilder,
          $$DoctorVisitsTableUpdateCompanionBuilder,
          (DoctorVisit, $$DoctorVisitsTableReferences),
          DoctorVisit,
          PrefetchHooks Function({bool profileId, bool doctorId})
        > {
  $$DoctorVisitsTableTableManager(_$AppDatabase db, $DoctorVisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoctorVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoctorVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoctorVisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<int> doctorId = const Value.absent(),
                Value<DateTime> visitDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderMinutesBefore = const Value.absent(),
              }) => DoctorVisitsCompanion(
                id: id,
                profileId: profileId,
                doctorId: doctorId,
                visitDate: visitDate,
                status: status,
                reason: reason,
                notes: notes,
                reminderEnabled: reminderEnabled,
                reminderMinutesBefore: reminderMinutesBefore,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required int doctorId,
                required DateTime visitDate,
                required String status,
                Value<String?> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderMinutesBefore = const Value.absent(),
              }) => DoctorVisitsCompanion.insert(
                id: id,
                profileId: profileId,
                doctorId: doctorId,
                visitDate: visitDate,
                status: status,
                reason: reason,
                notes: notes,
                reminderEnabled: reminderEnabled,
                reminderMinutesBefore: reminderMinutesBefore,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DoctorVisitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, doctorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$DoctorVisitsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$DoctorVisitsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (doctorId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.doctorId,
                                referencedTable: $$DoctorVisitsTableReferences
                                    ._doctorIdTable(db),
                                referencedColumn: $$DoctorVisitsTableReferences
                                    ._doctorIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DoctorVisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DoctorVisitsTable,
      DoctorVisit,
      $$DoctorVisitsTableFilterComposer,
      $$DoctorVisitsTableOrderingComposer,
      $$DoctorVisitsTableAnnotationComposer,
      $$DoctorVisitsTableCreateCompanionBuilder,
      $$DoctorVisitsTableUpdateCompanionBuilder,
      (DoctorVisit, $$DoctorVisitsTableReferences),
      DoctorVisit,
      PrefetchHooks Function({bool profileId, bool doctorId})
    >;
typedef $$DocumentAttachmentsTableCreateCompanionBuilder =
    DocumentAttachmentsCompanion Function({
      Value<int> id,
      required int profileId,
      required String category,
      required String title,
      required String fileName,
      required String mimeType,
      required String storedPath,
      Value<int?> fileSize,
      required DateTime createdAt,
      Value<String?> notes,
    });
typedef $$DocumentAttachmentsTableUpdateCompanionBuilder =
    DocumentAttachmentsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> category,
      Value<String> title,
      Value<String> fileName,
      Value<String> mimeType,
      Value<String> storedPath,
      Value<int?> fileSize,
      Value<DateTime> createdAt,
      Value<String?> notes,
    });

final class $$DocumentAttachmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DocumentAttachmentsTable,
          DocumentAttachment
        > {
  $$DocumentAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('document_attachments__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentAttachmentsTable> {
  $$DocumentAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storedPath => $composableBuilder(
    column: $table.storedPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentAttachmentsTable> {
  $$DocumentAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storedPath => $composableBuilder(
    column: $table.storedPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentAttachmentsTable> {
  $$DocumentAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get storedPath => $composableBuilder(
    column: $table.storedPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentAttachmentsTable,
          DocumentAttachment,
          $$DocumentAttachmentsTableFilterComposer,
          $$DocumentAttachmentsTableOrderingComposer,
          $$DocumentAttachmentsTableAnnotationComposer,
          $$DocumentAttachmentsTableCreateCompanionBuilder,
          $$DocumentAttachmentsTableUpdateCompanionBuilder,
          (DocumentAttachment, $$DocumentAttachmentsTableReferences),
          DocumentAttachment,
          PrefetchHooks Function({bool profileId})
        > {
  $$DocumentAttachmentsTableTableManager(
    _$AppDatabase db,
    $DocumentAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentAttachmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DocumentAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<String> storedPath = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DocumentAttachmentsCompanion(
                id: id,
                profileId: profileId,
                category: category,
                title: title,
                fileName: fileName,
                mimeType: mimeType,
                storedPath: storedPath,
                fileSize: fileSize,
                createdAt: createdAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String category,
                required String title,
                required String fileName,
                required String mimeType,
                required String storedPath,
                Value<int?> fileSize = const Value.absent(),
                required DateTime createdAt,
                Value<String?> notes = const Value.absent(),
              }) => DocumentAttachmentsCompanion.insert(
                id: id,
                profileId: profileId,
                category: category,
                title: title,
                fileName: fileName,
                mimeType: mimeType,
                storedPath: storedPath,
                fileSize: fileSize,
                createdAt: createdAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DocumentAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$DocumentAttachmentsTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$DocumentAttachmentsTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DocumentAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentAttachmentsTable,
      DocumentAttachment,
      $$DocumentAttachmentsTableFilterComposer,
      $$DocumentAttachmentsTableOrderingComposer,
      $$DocumentAttachmentsTableAnnotationComposer,
      $$DocumentAttachmentsTableCreateCompanionBuilder,
      $$DocumentAttachmentsTableUpdateCompanionBuilder,
      (DocumentAttachment, $$DocumentAttachmentsTableReferences),
      DocumentAttachment,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$DietPlansTableCreateCompanionBuilder =
    DietPlansCompanion Function({
      Value<int> id,
      required int profileId,
      required String title,
      Value<String?> description,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<bool> active,
      Value<String?> notes,
    });
typedef $$DietPlansTableUpdateCompanionBuilder =
    DietPlansCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> title,
      Value<String?> description,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<bool> active,
      Value<String?> notes,
    });

final class $$DietPlansTableReferences
    extends BaseReferences<_$AppDatabase, $DietPlansTable, DietPlan> {
  $$DietPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('diet_plans__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DietItemsTable, List<DietItem>>
  _dietItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dietItems,
    aliasName: 'diet_plans__id__diet_items__diet_plan_id',
  );

  $$DietItemsTableProcessedTableManager get dietItemsRefs {
    final manager = $$DietItemsTableTableManager(
      $_db,
      $_db.dietItems,
    ).filter((f) => f.dietPlanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dietItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DietPlansTableFilterComposer
    extends Composer<_$AppDatabase, $DietPlansTable> {
  $$DietPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> dietItemsRefs(
    Expression<bool> Function($$DietItemsTableFilterComposer f) f,
  ) {
    final $$DietItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dietItems,
      getReferencedColumn: (t) => t.dietPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DietItemsTableFilterComposer(
            $db: $db,
            $table: $db.dietItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DietPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $DietPlansTable> {
  $$DietPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DietPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $DietPlansTable> {
  $$DietPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> dietItemsRefs<T extends Object>(
    Expression<T> Function($$DietItemsTableAnnotationComposer a) f,
  ) {
    final $$DietItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dietItems,
      getReferencedColumn: (t) => t.dietPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DietItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.dietItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DietPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DietPlansTable,
          DietPlan,
          $$DietPlansTableFilterComposer,
          $$DietPlansTableOrderingComposer,
          $$DietPlansTableAnnotationComposer,
          $$DietPlansTableCreateCompanionBuilder,
          $$DietPlansTableUpdateCompanionBuilder,
          (DietPlan, $$DietPlansTableReferences),
          DietPlan,
          PrefetchHooks Function({bool profileId, bool dietItemsRefs})
        > {
  $$DietPlansTableTableManager(_$AppDatabase db, $DietPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DietPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DietPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DietPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DietPlansCompanion(
                id: id,
                profileId: profileId,
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                active: active,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DietPlansCompanion.insert(
                id: id,
                profileId: profileId,
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                active: active,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DietPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, dietItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dietItemsRefs) db.dietItems],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$DietPlansTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$DietPlansTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dietItemsRefs)
                    await $_getPrefetchedData<
                      DietPlan,
                      $DietPlansTable,
                      DietItem
                    >(
                      currentTable: table,
                      referencedTable: $$DietPlansTableReferences
                          ._dietItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DietPlansTableReferences(
                            db,
                            table,
                            p0,
                          ).dietItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.dietPlanId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DietPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DietPlansTable,
      DietPlan,
      $$DietPlansTableFilterComposer,
      $$DietPlansTableOrderingComposer,
      $$DietPlansTableAnnotationComposer,
      $$DietPlansTableCreateCompanionBuilder,
      $$DietPlansTableUpdateCompanionBuilder,
      (DietPlan, $$DietPlansTableReferences),
      DietPlan,
      PrefetchHooks Function({bool profileId, bool dietItemsRefs})
    >;
typedef $$DietItemsTableCreateCompanionBuilder =
    DietItemsCompanion Function({
      Value<int> id,
      required int dietPlanId,
      required String category,
      required String itemText,
      Value<String?> notes,
    });
typedef $$DietItemsTableUpdateCompanionBuilder =
    DietItemsCompanion Function({
      Value<int> id,
      Value<int> dietPlanId,
      Value<String> category,
      Value<String> itemText,
      Value<String?> notes,
    });

final class $$DietItemsTableReferences
    extends BaseReferences<_$AppDatabase, $DietItemsTable, DietItem> {
  $$DietItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DietPlansTable _dietPlanIdTable(_$AppDatabase db) =>
      db.dietPlans.createAlias('diet_items__diet_plan_id__diet_plans__id');

  $$DietPlansTableProcessedTableManager get dietPlanId {
    final $_column = $_itemColumn<int>('diet_plan_id')!;

    final manager = $$DietPlansTableTableManager(
      $_db,
      $_db.dietPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dietPlanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DietItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DietItemsTable> {
  $$DietItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemText => $composableBuilder(
    column: $table.itemText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$DietPlansTableFilterComposer get dietPlanId {
    final $$DietPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dietPlanId,
      referencedTable: $db.dietPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DietPlansTableFilterComposer(
            $db: $db,
            $table: $db.dietPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DietItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DietItemsTable> {
  $$DietItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemText => $composableBuilder(
    column: $table.itemText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$DietPlansTableOrderingComposer get dietPlanId {
    final $$DietPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dietPlanId,
      referencedTable: $db.dietPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DietPlansTableOrderingComposer(
            $db: $db,
            $table: $db.dietPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DietItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DietItemsTable> {
  $$DietItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get itemText =>
      $composableBuilder(column: $table.itemText, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$DietPlansTableAnnotationComposer get dietPlanId {
    final $$DietPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dietPlanId,
      referencedTable: $db.dietPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DietPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.dietPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DietItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DietItemsTable,
          DietItem,
          $$DietItemsTableFilterComposer,
          $$DietItemsTableOrderingComposer,
          $$DietItemsTableAnnotationComposer,
          $$DietItemsTableCreateCompanionBuilder,
          $$DietItemsTableUpdateCompanionBuilder,
          (DietItem, $$DietItemsTableReferences),
          DietItem,
          PrefetchHooks Function({bool dietPlanId})
        > {
  $$DietItemsTableTableManager(_$AppDatabase db, $DietItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DietItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DietItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DietItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dietPlanId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> itemText = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DietItemsCompanion(
                id: id,
                dietPlanId: dietPlanId,
                category: category,
                itemText: itemText,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dietPlanId,
                required String category,
                required String itemText,
                Value<String?> notes = const Value.absent(),
              }) => DietItemsCompanion.insert(
                id: id,
                dietPlanId: dietPlanId,
                category: category,
                itemText: itemText,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DietItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dietPlanId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dietPlanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dietPlanId,
                                referencedTable: $$DietItemsTableReferences
                                    ._dietPlanIdTable(db),
                                referencedColumn: $$DietItemsTableReferences
                                    ._dietPlanIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DietItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DietItemsTable,
      DietItem,
      $$DietItemsTableFilterComposer,
      $$DietItemsTableOrderingComposer,
      $$DietItemsTableAnnotationComposer,
      $$DietItemsTableCreateCompanionBuilder,
      $$DietItemsTableUpdateCompanionBuilder,
      (DietItem, $$DietItemsTableReferences),
      DietItem,
      PrefetchHooks Function({bool dietPlanId})
    >;
typedef $$HealthTemplatesTableCreateCompanionBuilder =
    HealthTemplatesCompanion Function({
      Value<int> id,
      required String name,
      required String description,
      required String configurationJson,
    });
typedef $$HealthTemplatesTableUpdateCompanionBuilder =
    HealthTemplatesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> description,
      Value<String> configurationJson,
    });

class $$HealthTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $HealthTemplatesTable> {
  $$HealthTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
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

  ColumnFilters<String> get configurationJson => $composableBuilder(
    column: $table.configurationJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthTemplatesTable> {
  $$HealthTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
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

  ColumnOrderings<String> get configurationJson => $composableBuilder(
    column: $table.configurationJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthTemplatesTable> {
  $$HealthTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configurationJson => $composableBuilder(
    column: $table.configurationJson,
    builder: (column) => column,
  );
}

class $$HealthTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthTemplatesTable,
          HealthTemplate,
          $$HealthTemplatesTableFilterComposer,
          $$HealthTemplatesTableOrderingComposer,
          $$HealthTemplatesTableAnnotationComposer,
          $$HealthTemplatesTableCreateCompanionBuilder,
          $$HealthTemplatesTableUpdateCompanionBuilder,
          (
            HealthTemplate,
            BaseReferences<
              _$AppDatabase,
              $HealthTemplatesTable,
              HealthTemplate
            >,
          ),
          HealthTemplate,
          PrefetchHooks Function()
        > {
  $$HealthTemplatesTableTableManager(
    _$AppDatabase db,
    $HealthTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> configurationJson = const Value.absent(),
              }) => HealthTemplatesCompanion(
                id: id,
                name: name,
                description: description,
                configurationJson: configurationJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String description,
                required String configurationJson,
              }) => HealthTemplatesCompanion.insert(
                id: id,
                name: name,
                description: description,
                configurationJson: configurationJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthTemplatesTable,
      HealthTemplate,
      $$HealthTemplatesTableFilterComposer,
      $$HealthTemplatesTableOrderingComposer,
      $$HealthTemplatesTableAnnotationComposer,
      $$HealthTemplatesTableCreateCompanionBuilder,
      $$HealthTemplatesTableUpdateCompanionBuilder,
      (
        HealthTemplate,
        BaseReferences<_$AppDatabase, $HealthTemplatesTable, HealthTemplate>,
      ),
      HealthTemplate,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
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

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$MedicationSchedulesTableTableManager get medicationSchedules =>
      $$MedicationSchedulesTableTableManager(_db, _db.medicationSchedules);
  $$MedicationLogsTableTableManager get medicationLogs =>
      $$MedicationLogsTableTableManager(_db, _db.medicationLogs);
  $$MedicationAlternativesTableTableManager get medicationAlternatives =>
      $$MedicationAlternativesTableTableManager(
        _db,
        _db.medicationAlternatives,
      );
  $$MeasurementTypesTableTableManager get measurementTypes =>
      $$MeasurementTypesTableTableManager(_db, _db.measurementTypes);
  $$MeasurementRecordsTableTableManager get measurementRecords =>
      $$MeasurementRecordsTableTableManager(_db, _db.measurementRecords);
  $$MeasurementSchedulesTableTableManager get measurementSchedules =>
      $$MeasurementSchedulesTableTableManager(_db, _db.measurementSchedules);
  $$ExerciseTypesTableTableManager get exerciseTypes =>
      $$ExerciseTypesTableTableManager(_db, _db.exerciseTypes);
  $$ExerciseGoalsTableTableManager get exerciseGoals =>
      $$ExerciseGoalsTableTableManager(_db, _db.exerciseGoals);
  $$ExerciseLogsTableTableManager get exerciseLogs =>
      $$ExerciseLogsTableTableManager(_db, _db.exerciseLogs);
  $$DoctorsTableTableManager get doctors =>
      $$DoctorsTableTableManager(_db, _db.doctors);
  $$DoctorVisitsTableTableManager get doctorVisits =>
      $$DoctorVisitsTableTableManager(_db, _db.doctorVisits);
  $$DocumentAttachmentsTableTableManager get documentAttachments =>
      $$DocumentAttachmentsTableTableManager(_db, _db.documentAttachments);
  $$DietPlansTableTableManager get dietPlans =>
      $$DietPlansTableTableManager(_db, _db.dietPlans);
  $$DietItemsTableTableManager get dietItems =>
      $$DietItemsTableTableManager(_db, _db.dietItems);
  $$HealthTemplatesTableTableManager get healthTemplates =>
      $$HealthTemplatesTableTableManager(_db, _db.healthTemplates);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
