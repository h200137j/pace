// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_unlock.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBadgeUnlockCollection on Isar {
  IsarCollection<BadgeUnlock> get badgeUnlocks => this.collection();
}

const BadgeUnlockSchema = CollectionSchema(
  name: r'BadgeUnlock',
  id: 2433630823679600184,
  properties: {
    r'badgeKey': PropertySchema(
      id: 0,
      name: r'badgeKey',
      type: IsarType.string,
    ),
    r'metadataJson': PropertySchema(
      id: 1,
      name: r'metadataJson',
      type: IsarType.string,
    ),
    r'progress': PropertySchema(
      id: 2,
      name: r'progress',
      type: IsarType.long,
    ),
    r'target': PropertySchema(
      id: 3,
      name: r'target',
      type: IsarType.long,
    ),
    r'tier': PropertySchema(
      id: 4,
      name: r'tier',
      type: IsarType.string,
    ),
    r'unlockedAt': PropertySchema(
      id: 5,
      name: r'unlockedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _badgeUnlockEstimateSize,
  serialize: _badgeUnlockSerialize,
  deserialize: _badgeUnlockDeserialize,
  deserializeProp: _badgeUnlockDeserializeProp,
  idName: r'id',
  indexes: {
    r'badgeKey': IndexSchema(
      id: 1194488592520037477,
      name: r'badgeKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'badgeKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _badgeUnlockGetId,
  getLinks: _badgeUnlockGetLinks,
  attach: _badgeUnlockAttach,
  version: '3.1.0+1',
);

int _badgeUnlockEstimateSize(
  BadgeUnlock object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.badgeKey.length * 3;
  {
    final value = object.metadataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tier.length * 3;
  return bytesCount;
}

void _badgeUnlockSerialize(
  BadgeUnlock object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.badgeKey);
  writer.writeString(offsets[1], object.metadataJson);
  writer.writeLong(offsets[2], object.progress);
  writer.writeLong(offsets[3], object.target);
  writer.writeString(offsets[4], object.tier);
  writer.writeDateTime(offsets[5], object.unlockedAt);
}

BadgeUnlock _badgeUnlockDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BadgeUnlock();
  object.badgeKey = reader.readString(offsets[0]);
  object.id = id;
  object.metadataJson = reader.readStringOrNull(offsets[1]);
  object.progress = reader.readLong(offsets[2]);
  object.target = reader.readLong(offsets[3]);
  object.tier = reader.readString(offsets[4]);
  object.unlockedAt = reader.readDateTimeOrNull(offsets[5]);
  return object;
}

P _badgeUnlockDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _badgeUnlockGetId(BadgeUnlock object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _badgeUnlockGetLinks(BadgeUnlock object) {
  return [];
}

void _badgeUnlockAttach(
    IsarCollection<dynamic> col, Id id, BadgeUnlock object) {
  object.id = id;
}

extension BadgeUnlockByIndex on IsarCollection<BadgeUnlock> {
  Future<BadgeUnlock?> getByBadgeKey(String badgeKey) {
    return getByIndex(r'badgeKey', [badgeKey]);
  }

  BadgeUnlock? getByBadgeKeySync(String badgeKey) {
    return getByIndexSync(r'badgeKey', [badgeKey]);
  }

  Future<bool> deleteByBadgeKey(String badgeKey) {
    return deleteByIndex(r'badgeKey', [badgeKey]);
  }

  bool deleteByBadgeKeySync(String badgeKey) {
    return deleteByIndexSync(r'badgeKey', [badgeKey]);
  }

  Future<List<BadgeUnlock?>> getAllByBadgeKey(List<String> badgeKeyValues) {
    final values = badgeKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'badgeKey', values);
  }

  List<BadgeUnlock?> getAllByBadgeKeySync(List<String> badgeKeyValues) {
    final values = badgeKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'badgeKey', values);
  }

  Future<int> deleteAllByBadgeKey(List<String> badgeKeyValues) {
    final values = badgeKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'badgeKey', values);
  }

  int deleteAllByBadgeKeySync(List<String> badgeKeyValues) {
    final values = badgeKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'badgeKey', values);
  }

  Future<Id> putByBadgeKey(BadgeUnlock object) {
    return putByIndex(r'badgeKey', object);
  }

  Id putByBadgeKeySync(BadgeUnlock object, {bool saveLinks = true}) {
    return putByIndexSync(r'badgeKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBadgeKey(List<BadgeUnlock> objects) {
    return putAllByIndex(r'badgeKey', objects);
  }

  List<Id> putAllByBadgeKeySync(List<BadgeUnlock> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'badgeKey', objects, saveLinks: saveLinks);
  }
}

extension BadgeUnlockQueryWhereSort
    on QueryBuilder<BadgeUnlock, BadgeUnlock, QWhere> {
  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BadgeUnlockQueryWhere
    on QueryBuilder<BadgeUnlock, BadgeUnlock, QWhereClause> {
  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterWhereClause> idBetween(
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

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterWhereClause> badgeKeyEqualTo(
      String badgeKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'badgeKey',
        value: [badgeKey],
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterWhereClause> badgeKeyNotEqualTo(
      String badgeKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeKey',
              lower: [],
              upper: [badgeKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeKey',
              lower: [badgeKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeKey',
              lower: [badgeKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeKey',
              lower: [],
              upper: [badgeKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BadgeUnlockQueryFilter
    on QueryBuilder<BadgeUnlock, BadgeUnlock, QFilterCondition> {
  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> badgeKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badgeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      badgeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'badgeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      badgeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'badgeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> badgeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'badgeKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      badgeKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'badgeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      badgeKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'badgeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      badgeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'badgeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> badgeKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'badgeKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      badgeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badgeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      badgeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'badgeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'metadataJson',
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'metadataJson',
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metadataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      metadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> progressEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      progressGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      progressLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> progressBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> targetEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'target',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      targetGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'target',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> targetLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'target',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> targetBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'target',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> tierEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> tierGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> tierLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> tierBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> tierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> tierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> tierContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> tierMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tier',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition> tierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tier',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      tierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tier',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      unlockedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      unlockedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      unlockedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      unlockedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      unlockedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterFilterCondition>
      unlockedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BadgeUnlockQueryObject
    on QueryBuilder<BadgeUnlock, BadgeUnlock, QFilterCondition> {}

extension BadgeUnlockQueryLinks
    on QueryBuilder<BadgeUnlock, BadgeUnlock, QFilterCondition> {}

extension BadgeUnlockQuerySortBy
    on QueryBuilder<BadgeUnlock, BadgeUnlock, QSortBy> {
  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> sortByBadgeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeKey', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> sortByBadgeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeKey', Sort.desc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> sortByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy>
      sortByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> sortByTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'target', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> sortByTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'target', Sort.desc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> sortByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> sortByTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.desc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> sortByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> sortByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension BadgeUnlockQuerySortThenBy
    on QueryBuilder<BadgeUnlock, BadgeUnlock, QSortThenBy> {
  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByBadgeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeKey', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByBadgeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeKey', Sort.desc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy>
      thenByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'target', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'target', Sort.desc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.desc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QAfterSortBy> thenByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension BadgeUnlockQueryWhereDistinct
    on QueryBuilder<BadgeUnlock, BadgeUnlock, QDistinct> {
  QueryBuilder<BadgeUnlock, BadgeUnlock, QDistinct> distinctByBadgeKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'badgeKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QDistinct> distinctByMetadataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QDistinct> distinctByTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'target');
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QDistinct> distinctByTier(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tier', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BadgeUnlock, BadgeUnlock, QDistinct> distinctByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAt');
    });
  }
}

extension BadgeUnlockQueryProperty
    on QueryBuilder<BadgeUnlock, BadgeUnlock, QQueryProperty> {
  QueryBuilder<BadgeUnlock, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BadgeUnlock, String, QQueryOperations> badgeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'badgeKey');
    });
  }

  QueryBuilder<BadgeUnlock, String?, QQueryOperations> metadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadataJson');
    });
  }

  QueryBuilder<BadgeUnlock, int, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<BadgeUnlock, int, QQueryOperations> targetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'target');
    });
  }

  QueryBuilder<BadgeUnlock, String, QQueryOperations> tierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tier');
    });
  }

  QueryBuilder<BadgeUnlock, DateTime?, QQueryOperations> unlockedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAt');
    });
  }
}
