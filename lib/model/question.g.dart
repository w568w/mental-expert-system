// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DBQuestion _$DBQuestionFromJson(Map<String, dynamic> json) => DBQuestion(
      json['question'] as String,
      json['symptom'] as String,
    );

Map<String, dynamic> _$DBQuestionToJson(DBQuestion instance) =>
    <String, dynamic>{
      'question': instance.question,
      'symptom': instance.symptom,
    };
