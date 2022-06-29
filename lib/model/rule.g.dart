// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DBRule _$DBRuleFromJson(Map<String, dynamic> json) => DBRule(
      DBExpression.fromJson(json['condition'] as Map<String, dynamic>),
      DBExpression.fromJson(json['conclusion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DBRuleToJson(DBRule instance) => <String, dynamic>{
      'condition': instance.condition,
      'conclusion': instance.conclusion,
    };
