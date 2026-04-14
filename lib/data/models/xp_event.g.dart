// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_event.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetXpEventCollection on Isar {
  IsarCollection<XpEvent> get xpEvents => this.collection();
}

const XpEventSchema = CollectionSchema(
  name: r'XpEvent',
  id: 5125805440905255218,
  properties: {
    r'awardedAt': PropertySchema(
      id: 0,
      name: r'awardedAt',
      type: IsarType.dateTime,
    ),
    r'baseXp': PropertySchema(
      id: 1,
      name: r'baseXp',
      type: IsarType.long,
    ),
    r'bonusXp': PropertySchema(
      id: 2,
      name: r'bonusXp',
      type: IsarType.long,
    ),
    r'eventKey': PropertySchema(
      id: 3,
      name: r'eventKey',
      type: IsarType.string,
    ),
    r'multiplier': PropertySchema(
      id: 4,
      name: r'multiplier',
      type: IsarType.double,
    ),
    r'note': PropertySchema(
      id: 5,
      name: r'note',
      type: IsarType.string,
    ),
    r'sourceId': PropertySchema(
      id: 6,
      name: r'sourceId',
      type: IsarType.string,
    ),
    r'sourceType': PropertySchema(
      id: 7,
      name: r'sourceType',
      type: IsarType.string,
    ),
    r'totalAwardedXp': PropertySchema(
      id: 8,
      name: r'totalAwardedXp',
      type: IsarType.long,
    )
  },
  estimateSize: _xpEventEstimateSize,
  serialize: _xpEventSerialize,
  deserialize: _xpEventDeserialize,
  deserializeProp: _xpEventDeserializeProp,
  idName: r'id',
  indexes: {
    r'eventKey': IndexSchema(
      id: -6167434590247707527,
      name: r'eventKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'eventKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'sourceType': IndexSchema(
      id: 5365578901051110922,
      name: r'sourceType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sourceType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _xpEventGetId,
  getLinks: _xpEventGetLinks,
  attach: _xpEventAttach,
  version: '3.1.0+1',
);

int _xpEventEstimateSize(
  XpEvent object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.eventKey.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sourceId.length * 3;
  bytesCount += 3 + object.sourceType.length * 3;
  return bytesCount;
}

void _xpEventSerialize(
  XpEvent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.awardedAt);
  writer.writeLong(offsets[1], object.baseXp);
  writer.writeLong(offsets[2], object.bonusXp);
  writer.writeString(offsets[3], object.eventKey);
  writer.writeDouble(offsets[4], object.multiplier);
  writer.writeString(offsets[5], object.note);
  writer.writeString(offsets[6], object.sourceId);
  writer.writeString(offsets[7], object.sourceType);
  writer.writeLong(offsets[8], object.totalAwardedXp);
}

XpEvent _xpEventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = XpEvent();
  object.awardedAt = reader.readDateTime(offsets[0]);
  object.baseXp = reader.readLong(offsets[1]);
  object.bonusXp = reader.readLong(offsets[2]);
  object.eventKey = reader.readString(offsets[3]);
  object.id = id;
  object.multiplier = reader.readDouble(offsets[4]);
  object.note = reader.readStringOrNull(offsets[5]);
  object.sourceId = reader.readString(offsets[6]);
  object.sourceType = reader.readString(offsets[7]);
  object.totalAwardedXp = reader.readLong(offsets[8]);
  return object;
}

P _xpEventDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _xpEventGetId(XpEvent object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _xpEventGetLinks(XpEvent object) {
  return [];
}

void _xpEventAttach(IsarCollection<dynamic> col, Id id, XpEvent object) {
  object.id = id;
}

extension XpEventByIndex on IsarCollection<XpEvent> {
  Future<XpEvent?> getByEventKey(String eventKey) {
    return getByIndex(r'eventKey', [eventKey]);
  }

  XpEvent? getByEventKeySync(String eventKey) {
    return getByIndexSync(r'eventKey', [eventKey]);
  }

  Future<bool> deleteByEventKey(String eventKey) {
    return deleteByIndex(r'eventKey', [eventKey]);
  }

  bool deleteByEventKeySync(String eventKey) {
    return deleteByIndexSync(r'eventKey', [eventKey]);
  }

  Future<List<XpEvent?>> getAllByEventKey(List<String> eventKeyValues) {
    final values = eventKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'eventKey', values);
  }

  List<XpEvent?> getAllByEventKeySync(List<String> eventKeyValues) {
    final values = eventKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'eventKey', values);
  }

  Future<int> deleteAllByEventKey(List<String> eventKeyValues) {
    final values = eventKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'eventKey', values);
  }

  int deleteAllByEventKeySync(List<String> eventKeyValues) {
    final values = eventKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'eventKey', values);
  }

  Future<Id> putByEventKey(XpEvent object) {
    return putByIndex(r'eventKey', object);
  }

  Id putByEventKeySync(XpEvent object, {bool saveLinks = true}) {
    return putByIndexSync(r'eventKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEventKey(List<XpEvent> objects) {
    return putAllByIndex(r'eventKey', objects);
  }

  List<Id> putAllByEventKeySync(List<XpEvent> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'eventKey', objects, saveLinks: saveLinks);
  }
}

extension XpEventQueryWhereSort on QueryBuilder<XpEvent, XpEvent, QWhere> {
  QueryBuilder<XpEvent, XpEvent, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension XpEventQueryWhere on QueryBuilder<XpEvent, XpEvent, QWhereClause> {
  QueryBuilder<XpEvent, XpEvent, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<XpEvent, XpEvent, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterWhereClause> idBetween(
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

  QueryBuilder<XpEvent, XpEvent, QAfterWhereClause> eventKeyEqualTo(
      String eventKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'eventKey',
        value: [eventKey],
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterWhereClause> eventKeyNotEqualTo(
      String eventKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventKey',
              lower: [],
              upper: [eventKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventKey',
              lower: [eventKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventKey',
              lower: [eventKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventKey',
              lower: [],
              upper: [eventKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterWhereClause> sourceTypeEqualTo(
      String sourceType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sourceType',
        value: [sourceType],
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterWhereClause> sourceTypeNotEqualTo(
      String sourceType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceType',
              lower: [],
              upper: [sourceType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceType',
              lower: [sourceType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceType',
              lower: [sourceType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceType',
              lower: [],
              upper: [sourceType],
              includeUpper: false,
            ));
      }
    });
  }
}

extension XpEventQueryFilter
    on QueryBuilder<XpEvent, XpEvent, QFilterCondition> {
  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> awardedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'awardedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> awardedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'awardedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> awardedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'awardedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> awardedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'awardedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> baseXpEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseXp',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> baseXpGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseXp',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> baseXpLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseXp',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> baseXpBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseXp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> bonusXpEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bonusXp',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> bonusXpGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bonusXp',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> bonusXpLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bonusXp',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> bonusXpBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bonusXp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> eventKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> eventKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> eventKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> eventKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> eventKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eventKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> eventKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eventKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> eventKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eventKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> eventKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eventKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> eventKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventKey',
        value: '',
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> eventKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eventKey',
        value: '',
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> idBetween(
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

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> multiplierEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'multiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> multiplierGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'multiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> multiplierLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'multiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> multiplierBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'multiplier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: '',
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> sourceTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceType',
        value: '',
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> totalAwardedXpEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAwardedXp',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition>
      totalAwardedXpGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAwardedXp',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> totalAwardedXpLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAwardedXp',
        value: value,
      ));
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterFilterCondition> totalAwardedXpBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAwardedXp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension XpEventQueryObject
    on QueryBuilder<XpEvent, XpEvent, QFilterCondition> {}

extension XpEventQueryLinks
    on QueryBuilder<XpEvent, XpEvent, QFilterCondition> {}

extension XpEventQuerySortBy on QueryBuilder<XpEvent, XpEvent, QSortBy> {
  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByAwardedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awardedAt', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByAwardedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awardedAt', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByBaseXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseXp', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByBaseXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseXp', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByBonusXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonusXp', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByBonusXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonusXp', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByEventKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventKey', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByEventKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventKey', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'multiplier', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByMultiplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'multiplier', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByTotalAwardedXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAwardedXp', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> sortByTotalAwardedXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAwardedXp', Sort.desc);
    });
  }
}

extension XpEventQuerySortThenBy
    on QueryBuilder<XpEvent, XpEvent, QSortThenBy> {
  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByAwardedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awardedAt', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByAwardedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awardedAt', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByBaseXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseXp', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByBaseXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseXp', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByBonusXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonusXp', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByBonusXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonusXp', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByEventKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventKey', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByEventKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventKey', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'multiplier', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByMultiplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'multiplier', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByTotalAwardedXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAwardedXp', Sort.asc);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QAfterSortBy> thenByTotalAwardedXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAwardedXp', Sort.desc);
    });
  }
}

extension XpEventQueryWhereDistinct
    on QueryBuilder<XpEvent, XpEvent, QDistinct> {
  QueryBuilder<XpEvent, XpEvent, QDistinct> distinctByAwardedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'awardedAt');
    });
  }

  QueryBuilder<XpEvent, XpEvent, QDistinct> distinctByBaseXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseXp');
    });
  }

  QueryBuilder<XpEvent, XpEvent, QDistinct> distinctByBonusXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bonusXp');
    });
  }

  QueryBuilder<XpEvent, XpEvent, QDistinct> distinctByEventKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QDistinct> distinctByMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'multiplier');
    });
  }

  QueryBuilder<XpEvent, XpEvent, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QDistinct> distinctBySourceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QDistinct> distinctBySourceType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<XpEvent, XpEvent, QDistinct> distinctByTotalAwardedXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAwardedXp');
    });
  }
}

extension XpEventQueryProperty
    on QueryBuilder<XpEvent, XpEvent, QQueryProperty> {
  QueryBuilder<XpEvent, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<XpEvent, DateTime, QQueryOperations> awardedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'awardedAt');
    });
  }

  QueryBuilder<XpEvent, int, QQueryOperations> baseXpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseXp');
    });
  }

  QueryBuilder<XpEvent, int, QQueryOperations> bonusXpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bonusXp');
    });
  }

  QueryBuilder<XpEvent, String, QQueryOperations> eventKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventKey');
    });
  }

  QueryBuilder<XpEvent, double, QQueryOperations> multiplierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'multiplier');
    });
  }

  QueryBuilder<XpEvent, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<XpEvent, String, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<XpEvent, String, QQueryOperations> sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceType');
    });
  }

  QueryBuilder<XpEvent, int, QQueryOperations> totalAwardedXpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAwardedXp');
    });
  }
}
