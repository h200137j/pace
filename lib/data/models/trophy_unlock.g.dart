// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trophy_unlock.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTrophyUnlockCollection on Isar {
  IsarCollection<TrophyUnlock> get trophyUnlocks => this.collection();
}

const TrophyUnlockSchema = CollectionSchema(
  name: r'TrophyUnlock',
  id: -3148529246117328871,
  properties: {
    r'metadataJson': PropertySchema(
      id: 0,
      name: r'metadataJson',
      type: IsarType.string,
    ),
    r'progress': PropertySchema(
      id: 1,
      name: r'progress',
      type: IsarType.long,
    ),
    r'target': PropertySchema(
      id: 2,
      name: r'target',
      type: IsarType.long,
    ),
    r'trophyKey': PropertySchema(
      id: 3,
      name: r'trophyKey',
      type: IsarType.string,
    ),
    r'unlockedAt': PropertySchema(
      id: 4,
      name: r'unlockedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _trophyUnlockEstimateSize,
  serialize: _trophyUnlockSerialize,
  deserialize: _trophyUnlockDeserialize,
  deserializeProp: _trophyUnlockDeserializeProp,
  idName: r'id',
  indexes: {
    r'trophyKey': IndexSchema(
      id: -5762049712966810163,
      name: r'trophyKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'trophyKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _trophyUnlockGetId,
  getLinks: _trophyUnlockGetLinks,
  attach: _trophyUnlockAttach,
  version: '3.1.0+1',
);

int _trophyUnlockEstimateSize(
  TrophyUnlock object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.metadataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.trophyKey.length * 3;
  return bytesCount;
}

void _trophyUnlockSerialize(
  TrophyUnlock object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.metadataJson);
  writer.writeLong(offsets[1], object.progress);
  writer.writeLong(offsets[2], object.target);
  writer.writeString(offsets[3], object.trophyKey);
  writer.writeDateTime(offsets[4], object.unlockedAt);
}

TrophyUnlock _trophyUnlockDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TrophyUnlock();
  object.id = id;
  object.metadataJson = reader.readStringOrNull(offsets[0]);
  object.progress = reader.readLong(offsets[1]);
  object.target = reader.readLong(offsets[2]);
  object.trophyKey = reader.readString(offsets[3]);
  object.unlockedAt = reader.readDateTimeOrNull(offsets[4]);
  return object;
}

P _trophyUnlockDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _trophyUnlockGetId(TrophyUnlock object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _trophyUnlockGetLinks(TrophyUnlock object) {
  return [];
}

void _trophyUnlockAttach(
    IsarCollection<dynamic> col, Id id, TrophyUnlock object) {
  object.id = id;
}

extension TrophyUnlockByIndex on IsarCollection<TrophyUnlock> {
  Future<TrophyUnlock?> getByTrophyKey(String trophyKey) {
    return getByIndex(r'trophyKey', [trophyKey]);
  }

  TrophyUnlock? getByTrophyKeySync(String trophyKey) {
    return getByIndexSync(r'trophyKey', [trophyKey]);
  }

  Future<bool> deleteByTrophyKey(String trophyKey) {
    return deleteByIndex(r'trophyKey', [trophyKey]);
  }

  bool deleteByTrophyKeySync(String trophyKey) {
    return deleteByIndexSync(r'trophyKey', [trophyKey]);
  }

  Future<List<TrophyUnlock?>> getAllByTrophyKey(List<String> trophyKeyValues) {
    final values = trophyKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'trophyKey', values);
  }

  List<TrophyUnlock?> getAllByTrophyKeySync(List<String> trophyKeyValues) {
    final values = trophyKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'trophyKey', values);
  }

  Future<int> deleteAllByTrophyKey(List<String> trophyKeyValues) {
    final values = trophyKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'trophyKey', values);
  }

  int deleteAllByTrophyKeySync(List<String> trophyKeyValues) {
    final values = trophyKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'trophyKey', values);
  }

  Future<Id> putByTrophyKey(TrophyUnlock object) {
    return putByIndex(r'trophyKey', object);
  }

  Id putByTrophyKeySync(TrophyUnlock object, {bool saveLinks = true}) {
    return putByIndexSync(r'trophyKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTrophyKey(List<TrophyUnlock> objects) {
    return putAllByIndex(r'trophyKey', objects);
  }

  List<Id> putAllByTrophyKeySync(List<TrophyUnlock> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'trophyKey', objects, saveLinks: saveLinks);
  }
}

extension TrophyUnlockQueryWhereSort
    on QueryBuilder<TrophyUnlock, TrophyUnlock, QWhere> {
  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TrophyUnlockQueryWhere
    on QueryBuilder<TrophyUnlock, TrophyUnlock, QWhereClause> {
  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterWhereClause> idBetween(
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterWhereClause> trophyKeyEqualTo(
      String trophyKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'trophyKey',
        value: [trophyKey],
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterWhereClause>
      trophyKeyNotEqualTo(String trophyKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trophyKey',
              lower: [],
              upper: [trophyKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trophyKey',
              lower: [trophyKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trophyKey',
              lower: [trophyKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trophyKey',
              lower: [],
              upper: [trophyKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TrophyUnlockQueryFilter
    on QueryBuilder<TrophyUnlock, TrophyUnlock, QFilterCondition> {
  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      metadataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'metadataJson',
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      metadataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'metadataJson',
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      metadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      metadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      metadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      metadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      progressEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      progressBetween(
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition> targetEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'target',
        value: value,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      targetLessThan(
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition> targetBetween(
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      trophyKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trophyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      trophyKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trophyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      trophyKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trophyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      trophyKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trophyKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      trophyKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'trophyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      trophyKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'trophyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      trophyKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'trophyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      trophyKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'trophyKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      trophyKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trophyKey',
        value: '',
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      trophyKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trophyKey',
        value: '',
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      unlockedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      unlockedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
      unlockedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterFilterCondition>
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

extension TrophyUnlockQueryObject
    on QueryBuilder<TrophyUnlock, TrophyUnlock, QFilterCondition> {}

extension TrophyUnlockQueryLinks
    on QueryBuilder<TrophyUnlock, TrophyUnlock, QFilterCondition> {}

extension TrophyUnlockQuerySortBy
    on QueryBuilder<TrophyUnlock, TrophyUnlock, QSortBy> {
  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> sortByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy>
      sortByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> sortByTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'target', Sort.asc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> sortByTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'target', Sort.desc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> sortByTrophyKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trophyKey', Sort.asc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> sortByTrophyKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trophyKey', Sort.desc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> sortByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy>
      sortByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension TrophyUnlockQuerySortThenBy
    on QueryBuilder<TrophyUnlock, TrophyUnlock, QSortThenBy> {
  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> thenByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy>
      thenByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> thenByTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'target', Sort.asc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> thenByTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'target', Sort.desc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> thenByTrophyKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trophyKey', Sort.asc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> thenByTrophyKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trophyKey', Sort.desc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy> thenByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QAfterSortBy>
      thenByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension TrophyUnlockQueryWhereDistinct
    on QueryBuilder<TrophyUnlock, TrophyUnlock, QDistinct> {
  QueryBuilder<TrophyUnlock, TrophyUnlock, QDistinct> distinctByMetadataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QDistinct> distinctByTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'target');
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QDistinct> distinctByTrophyKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trophyKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrophyUnlock, TrophyUnlock, QDistinct> distinctByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAt');
    });
  }
}

extension TrophyUnlockQueryProperty
    on QueryBuilder<TrophyUnlock, TrophyUnlock, QQueryProperty> {
  QueryBuilder<TrophyUnlock, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TrophyUnlock, String?, QQueryOperations> metadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadataJson');
    });
  }

  QueryBuilder<TrophyUnlock, int, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<TrophyUnlock, int, QQueryOperations> targetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'target');
    });
  }

  QueryBuilder<TrophyUnlock, String, QQueryOperations> trophyKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trophyKey');
    });
  }

  QueryBuilder<TrophyUnlock, DateTime?, QQueryOperations> unlockedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAt');
    });
  }
}
