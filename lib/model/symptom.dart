import 'package:json_annotation/json_annotation.dart';

part 'symptom.g.dart';

@JsonSerializable()
class DBSymptom {
  // 一级症状
  final String superSymptom;
  // 下属二级症状
  final List<String> symptom;

  DBSymptom(this.superSymptom, this.symptom);

  factory DBSymptom.fromJson(Map<String, dynamic> json) => _$DBSymptomFromJson(json);

  Map<String, dynamic> toJson() => _$DBSymptomToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DBSymptom &&
          runtimeType == other.runtimeType &&
          superSymptom == other.superSymptom &&
          symptom == other.symptom;

  @override
  int get hashCode => superSymptom.hashCode ^ symptom.hashCode;
}