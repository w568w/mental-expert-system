// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DBExpression _$DBExpressionFromJson(Map<String, dynamic> json) => DBExpression(
      json['type'] as int,
      json['first'] == null
          ? null
          : DBExpression.fromJson(json['first'] as Map<String, dynamic>),
      json['second'] == null
          ? null
          : DBExpression.fromJson(json['second'] as Map<String, dynamic>),
      json['variable'] as String?,
      json['modifier'] == null
          ? null
          : DBFuzzySet.fromJson(json['modifier'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DBExpressionToJson(DBExpression instance) =>
    <String, dynamic>{
      'type': instance.type,
      'first': instance.first,
      'second': instance.second,
      'variable': instance.variable,
      'modifier': instance.modifier,
    };

DBFuzzySet _$DBFuzzySetFromJson(Map<String, dynamic> json) => DBFuzzySet(
      json['level'] as int,
      json['very'] as bool,
      json['not'] as bool,
    );

Map<String, dynamic> _$DBFuzzySetToJson(DBFuzzySet instance) =>
    <String, dynamic>{
      'level': instance.level,
      'very': instance.very,
      'not': instance.not,
    };
