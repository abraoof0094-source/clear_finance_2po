// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetForecastItemCollection on Isar {
  IsarCollection<ForecastItem> get forecastItems => this.collection();
}

const ForecastItemSchema = CollectionSchema(
  name: r'ForecastItem',
  id: -822877950605119035,
  properties: {
    r'billingDay': PropertySchema(
      id: 0,
      name: r'billingDay',
      type: IsarType.long,
    ),
    r'categoryId': PropertySchema(
      id: 1,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'colorValue': PropertySchema(
      id: 2,
      name: r'colorValue',
      type: IsarType.long,
    ),
    r'currentOutstanding': PropertySchema(
      id: 3,
      name: r'currentOutstanding',
      type: IsarType.double,
    ),
    r'icon': PropertySchema(
      id: 4,
      name: r'icon',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 5,
      name: r'id',
      type: IsarType.string,
    ),
    r'interestRate': PropertySchema(
      id: 6,
      name: r'interestRate',
      type: IsarType.double,
    ),
    r'isLiability': PropertySchema(
      id: 7,
      name: r'isLiability',
      type: IsarType.bool,
    ),
    r'monthlyEmiOrContribution': PropertySchema(
      id: 8,
      name: r'monthlyEmiOrContribution',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 9,
      name: r'name',
      type: IsarType.string,
    ),
    r'targetAmount': PropertySchema(
      id: 10,
      name: r'targetAmount',
      type: IsarType.double,
    ),
    r'type': PropertySchema(
      id: 11,
      name: r'type',
      type: IsarType.byte,
      enumMap: _ForecastItemtypeEnumValueMap,
    )
  },
  estimateSize: _forecastItemEstimateSize,
  serialize: _forecastItemSerialize,
  deserialize: _forecastItemDeserialize,
  deserializeProp: _forecastItemDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _forecastItemGetId,
  getLinks: _forecastItemGetLinks,
  attach: _forecastItemAttach,
  version: '3.1.0+1',
);

int _forecastItemEstimateSize(
  ForecastItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.icon.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _forecastItemSerialize(
  ForecastItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.billingDay);
  writer.writeLong(offsets[1], object.categoryId);
  writer.writeLong(offsets[2], object.colorValue);
  writer.writeDouble(offsets[3], object.currentOutstanding);
  writer.writeString(offsets[4], object.icon);
  writer.writeString(offsets[5], object.id);
  writer.writeDouble(offsets[6], object.interestRate);
  writer.writeBool(offsets[7], object.isLiability);
  writer.writeDouble(offsets[8], object.monthlyEmiOrContribution);
  writer.writeString(offsets[9], object.name);
  writer.writeDouble(offsets[10], object.targetAmount);
  writer.writeByte(offsets[11], object.type.index);
}

ForecastItem _forecastItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ForecastItem(
    billingDay: reader.readLongOrNull(offsets[0]) ?? 1,
    categoryId: reader.readLongOrNull(offsets[1]),
    colorValue: reader.readLong(offsets[2]),
    currentOutstanding: reader.readDouble(offsets[3]),
    icon: reader.readString(offsets[4]),
    id: reader.readString(offsets[5]),
    interestRate: reader.readDoubleOrNull(offsets[6]) ?? 0,
    isarId: id,
    monthlyEmiOrContribution: reader.readDoubleOrNull(offsets[8]) ?? 0,
    name: reader.readString(offsets[9]),
    targetAmount: reader.readDouble(offsets[10]),
    type: _ForecastItemtypeValueEnumMap[reader.readByteOrNull(offsets[11])] ??
        ForecastType.emiAmortized,
  );
  return object;
}

P _forecastItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 1) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (_ForecastItemtypeValueEnumMap[reader.readByteOrNull(offset)] ??
          ForecastType.emiAmortized) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ForecastItemtypeEnumValueMap = {
  'emiAmortized': 0,
  'emiInterestOnly': 1,
  'debtSimple': 2,
  'goalTarget': 3,
};
const _ForecastItemtypeValueEnumMap = {
  0: ForecastType.emiAmortized,
  1: ForecastType.emiInterestOnly,
  2: ForecastType.debtSimple,
  3: ForecastType.goalTarget,
};

Id _forecastItemGetId(ForecastItem object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _forecastItemGetLinks(ForecastItem object) {
  return [];
}

void _forecastItemAttach(
    IsarCollection<dynamic> col, Id id, ForecastItem object) {
  object.isarId = id;
}

extension ForecastItemByIndex on IsarCollection<ForecastItem> {
  Future<ForecastItem?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  ForecastItem? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<ForecastItem?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<ForecastItem?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(ForecastItem object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(ForecastItem object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<ForecastItem> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<ForecastItem> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension ForecastItemQueryWhereSort
    on QueryBuilder<ForecastItem, ForecastItem, QWhere> {
  QueryBuilder<ForecastItem, ForecastItem, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ForecastItemQueryWhere
    on QueryBuilder<ForecastItem, ForecastItem, QWhereClause> {
  QueryBuilder<ForecastItem, ForecastItem, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterWhereClause> idNotEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ForecastItemQueryFilter
    on QueryBuilder<ForecastItem, ForecastItem, QFilterCondition> {
  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      billingDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billingDay',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      billingDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'billingDay',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      billingDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'billingDay',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      billingDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'billingDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'categoryId',
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      categoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'categoryId',
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      categoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      categoryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      categoryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      categoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      colorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      colorValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      colorValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      colorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      currentOutstandingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentOutstanding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      currentOutstandingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentOutstanding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      currentOutstandingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentOutstanding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      currentOutstandingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentOutstanding',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> iconEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      iconGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> iconLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> iconBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'icon',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      iconStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> iconEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> iconContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> iconMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'icon',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      iconIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      iconIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      interestRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      interestRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      interestRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      interestRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interestRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      isLiabilityEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLiability',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      monthlyEmiOrContributionEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthlyEmiOrContribution',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      monthlyEmiOrContributionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthlyEmiOrContribution',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      monthlyEmiOrContributionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthlyEmiOrContribution',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      monthlyEmiOrContributionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthlyEmiOrContribution',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      targetAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      targetAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      targetAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      targetAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> typeEqualTo(
      ForecastType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition>
      typeGreaterThan(
    ForecastType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> typeLessThan(
    ForecastType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterFilterCondition> typeBetween(
    ForecastType lower,
    ForecastType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ForecastItemQueryObject
    on QueryBuilder<ForecastItem, ForecastItem, QFilterCondition> {}

extension ForecastItemQueryLinks
    on QueryBuilder<ForecastItem, ForecastItem, QFilterCondition> {}

extension ForecastItemQuerySortBy
    on QueryBuilder<ForecastItem, ForecastItem, QSortBy> {
  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByBillingDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingDay', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      sortByBillingDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingDay', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      sortByCurrentOutstanding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentOutstanding', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      sortByCurrentOutstandingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentOutstanding', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      sortByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByIsLiability() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiability', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      sortByIsLiabilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiability', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      sortByMonthlyEmiOrContribution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyEmiOrContribution', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      sortByMonthlyEmiOrContributionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyEmiOrContribution', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      sortByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ForecastItemQuerySortThenBy
    on QueryBuilder<ForecastItem, ForecastItem, QSortThenBy> {
  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByBillingDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingDay', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      thenByBillingDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingDay', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      thenByCurrentOutstanding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentOutstanding', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      thenByCurrentOutstandingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentOutstanding', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      thenByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByIsLiability() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiability', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      thenByIsLiabilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiability', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      thenByMonthlyEmiOrContribution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyEmiOrContribution', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      thenByMonthlyEmiOrContributionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyEmiOrContribution', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy>
      thenByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ForecastItemQueryWhereDistinct
    on QueryBuilder<ForecastItem, ForecastItem, QDistinct> {
  QueryBuilder<ForecastItem, ForecastItem, QDistinct> distinctByBillingDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billingDay');
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QDistinct> distinctByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId');
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QDistinct> distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorValue');
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QDistinct>
      distinctByCurrentOutstanding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentOutstanding');
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QDistinct> distinctByIcon(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'icon', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QDistinct> distinctByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestRate');
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QDistinct> distinctByIsLiability() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLiability');
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QDistinct>
      distinctByMonthlyEmiOrContribution() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthlyEmiOrContribution');
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QDistinct> distinctByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetAmount');
    });
  }

  QueryBuilder<ForecastItem, ForecastItem, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension ForecastItemQueryProperty
    on QueryBuilder<ForecastItem, ForecastItem, QQueryProperty> {
  QueryBuilder<ForecastItem, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ForecastItem, int, QQueryOperations> billingDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billingDay');
    });
  }

  QueryBuilder<ForecastItem, int?, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<ForecastItem, int, QQueryOperations> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorValue');
    });
  }

  QueryBuilder<ForecastItem, double, QQueryOperations>
      currentOutstandingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentOutstanding');
    });
  }

  QueryBuilder<ForecastItem, String, QQueryOperations> iconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'icon');
    });
  }

  QueryBuilder<ForecastItem, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ForecastItem, double, QQueryOperations> interestRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestRate');
    });
  }

  QueryBuilder<ForecastItem, bool, QQueryOperations> isLiabilityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLiability');
    });
  }

  QueryBuilder<ForecastItem, double, QQueryOperations>
      monthlyEmiOrContributionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthlyEmiOrContribution');
    });
  }

  QueryBuilder<ForecastItem, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ForecastItem, double, QQueryOperations> targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetAmount');
    });
  }

  QueryBuilder<ForecastItem, ForecastType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
