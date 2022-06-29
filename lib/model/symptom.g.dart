// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DBSymptom _$DBSymptomFromJson(Map<String, dynamic> json) => DBSymptom(
      json['superSymptom'] as String,
      (json['symptom'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DBSymptomToJson(DBSymptom instance) => <String, dynamic>{
      'superSymptom': instance.superSymptom,
      'symptom': instance.symptom,
    };
