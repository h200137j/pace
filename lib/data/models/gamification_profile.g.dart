// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGamificationProfileCollection on Isar {
  IsarCollection<GamificationProfile> get gamificationProfiles =>
      this.collection();
}

const GamificationProfileSchema = CollectionSchema(
  name: r'GamificationProfile',
  id: 7765942574631933894,
  properties: {
    r'currentLevel': PropertySchema(
      id: 0,
      name: r'currentLevel',
      type: IsarType.long,
    ),
    r'lastAwardedAt': PropertySchema(
      id: 1,
      name: r'lastAwardedAt',
      type: IsarType.dateTime,
    ),
    r'lifetimeCompletions': PropertySchema(
      id: 2,
      name: r'lifetimeCompletions',
      type: IsarType.long,
    ),
    r'lifetimePhotoCompletions': PropertySchema(
      id: 3,
      name: r'lifetimePhotoCompletions',
      type: IsarType.long,
    ),
    r'totalXp': PropertySchema(
      id: 4,
      name: r'totalXp',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'xpForNextLevel': PropertySchema(
      id: 6,
      name: r'xpForNextLevel',
      type: IsarType.long,
    ),
    r'xpIntoCurrentLevel': PropertySchema(
      id: 7,
      name: r'xpIntoCurrentLevel',
      type: IsarType.long,
    )
  },
  estimateSize: _gamificationProfileEstimateSize,
  serialize: _gamificationProfileSerialize,
  deserialize: _gamificationProfileDeserialize,
  deserializeProp: _gamificationProfileDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _gamificationProfileGetId,
  getLinks: _gamificationProfileGetLinks,
  attach: _gamificationProfileAttach,
  version: '3.1.0+1',
);

int _gamificationProfileEstimateSize(
  GamificationProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _gamificationProfileSerialize(
  GamificationProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentLevel);
  writer.writeDateTime(offsets[1], object.lastAwardedAt);
  writer.writeLong(offsets[2], object.lifetimeCompletions);
  writer.writeLong(offsets[3], object.lifetimePhotoCompletions);
  writer.writeLong(offsets[4], object.totalXp);
  writer.writeDateTime(offsets[5], object.updatedAt);
  writer.writeLong(offsets[6], object.xpForNextLevel);
  writer.writeLong(offsets[7], object.xpIntoCurrentLevel);
}

GamificationProfile _gamificationProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GamificationProfile();
  object.currentLevel = reader.readLong(offsets[0]);
  object.id = id;
  object.lastAwardedAt = reader.readDateTimeOrNull(offsets[1]);
  object.lifetimeCompletions = reader.readLong(offsets[2]);
  object.lifetimePhotoCompletions = reader.readLong(offsets[3]);
  object.totalXp = reader.readLong(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  object.xpForNextLevel = reader.readLong(offsets[6]);
  object.xpIntoCurrentLevel = reader.readLong(offsets[7]);
  return object;
}

P _gamificationProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _gamificationProfileGetId(GamificationProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _gamificationProfileGetLinks(
    GamificationProfile object) {
  return [];
}

void _gamificationProfileAttach(
    IsarCollection<dynamic> col, Id id, GamificationProfile object) {
  object.id = id;
}

extension GamificationProfileQueryWhereSort
    on QueryBuilder<GamificationProfile, GamificationProfile, QWhere> {
  QueryBuilder<GamificationProfile, GamificationProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GamificationProfileQueryWhere
    on QueryBuilder<GamificationProfile, GamificationProfile, QWhereClause> {
  QueryBuilder<GamificationProfile, GamificationProfile, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension GamificationProfileQueryFilter on QueryBuilder<GamificationProfile,
    GamificationProfile, QFilterCondition> {
  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      currentLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      currentLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      currentLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      currentLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lastAwardedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastAwardedAt',
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lastAwardedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastAwardedAt',
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lastAwardedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAwardedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lastAwardedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAwardedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lastAwardedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAwardedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lastAwardedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAwardedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lifetimeCompletionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lifetimeCompletions',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lifetimeCompletionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lifetimeCompletions',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lifetimeCompletionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lifetimeCompletions',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lifetimeCompletionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lifetimeCompletions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lifetimePhotoCompletionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lifetimePhotoCompletions',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lifetimePhotoCompletionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lifetimePhotoCompletions',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lifetimePhotoCompletionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lifetimePhotoCompletions',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      lifetimePhotoCompletionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lifetimePhotoCompletions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      totalXpEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalXp',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      totalXpGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalXp',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      totalXpLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalXp',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      totalXpBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalXp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      xpForNextLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xpForNextLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      xpForNextLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xpForNextLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      xpForNextLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xpForNextLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      xpForNextLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xpForNextLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      xpIntoCurrentLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xpIntoCurrentLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      xpIntoCurrentLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xpIntoCurrentLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      xpIntoCurrentLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xpIntoCurrentLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterFilterCondition>
      xpIntoCurrentLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xpIntoCurrentLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension GamificationProfileQueryObject on QueryBuilder<GamificationProfile,
    GamificationProfile, QFilterCondition> {}

extension GamificationProfileQueryLinks on QueryBuilder<GamificationProfile,
    GamificationProfile, QFilterCondition> {}

extension GamificationProfileQuerySortBy
    on QueryBuilder<GamificationProfile, GamificationProfile, QSortBy> {
  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByCurrentLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLevel', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByCurrentLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLevel', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByLastAwardedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAwardedAt', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByLastAwardedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAwardedAt', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByLifetimeCompletions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeCompletions', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByLifetimeCompletionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeCompletions', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByLifetimePhotoCompletions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimePhotoCompletions', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByLifetimePhotoCompletionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimePhotoCompletions', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByTotalXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByTotalXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByXpForNextLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpForNextLevel', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByXpForNextLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpForNextLevel', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByXpIntoCurrentLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpIntoCurrentLevel', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      sortByXpIntoCurrentLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpIntoCurrentLevel', Sort.desc);
    });
  }
}

extension GamificationProfileQuerySortThenBy
    on QueryBuilder<GamificationProfile, GamificationProfile, QSortThenBy> {
  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByCurrentLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLevel', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByCurrentLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLevel', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByLastAwardedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAwardedAt', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByLastAwardedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAwardedAt', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByLifetimeCompletions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeCompletions', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByLifetimeCompletionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeCompletions', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByLifetimePhotoCompletions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimePhotoCompletions', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByLifetimePhotoCompletionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimePhotoCompletions', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByTotalXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByTotalXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByXpForNextLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpForNextLevel', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByXpForNextLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpForNextLevel', Sort.desc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByXpIntoCurrentLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpIntoCurrentLevel', Sort.asc);
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QAfterSortBy>
      thenByXpIntoCurrentLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpIntoCurrentLevel', Sort.desc);
    });
  }
}

extension GamificationProfileQueryWhereDistinct
    on QueryBuilder<GamificationProfile, GamificationProfile, QDistinct> {
  QueryBuilder<GamificationProfile, GamificationProfile, QDistinct>
      distinctByCurrentLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentLevel');
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QDistinct>
      distinctByLastAwardedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAwardedAt');
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QDistinct>
      distinctByLifetimeCompletions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lifetimeCompletions');
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QDistinct>
      distinctByLifetimePhotoCompletions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lifetimePhotoCompletions');
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QDistinct>
      distinctByTotalXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalXp');
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QDistinct>
      distinctByXpForNextLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xpForNextLevel');
    });
  }

  QueryBuilder<GamificationProfile, GamificationProfile, QDistinct>
      distinctByXpIntoCurrentLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xpIntoCurrentLevel');
    });
  }
}

extension GamificationProfileQueryProperty
    on QueryBuilder<GamificationProfile, GamificationProfile, QQueryProperty> {
  QueryBuilder<GamificationProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GamificationProfile, int, QQueryOperations>
      currentLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentLevel');
    });
  }

  QueryBuilder<GamificationProfile, DateTime?, QQueryOperations>
      lastAwardedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAwardedAt');
    });
  }

  QueryBuilder<GamificationProfile, int, QQueryOperations>
      lifetimeCompletionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lifetimeCompletions');
    });
  }

  QueryBuilder<GamificationProfile, int, QQueryOperations>
      lifetimePhotoCompletionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lifetimePhotoCompletions');
    });
  }

  QueryBuilder<GamificationProfile, int, QQueryOperations> totalXpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalXp');
    });
  }

  QueryBuilder<GamificationProfile, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<GamificationProfile, int, QQueryOperations>
      xpForNextLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xpForNextLevel');
    });
  }

  QueryBuilder<GamificationProfile, int, QQueryOperations>
      xpIntoCurrentLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xpIntoCurrentLevel');
    });
  }
}
