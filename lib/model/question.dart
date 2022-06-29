import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class DBQuestion {
  final String question;
  // 对应的二级症状
  final String symptom;

  DBQuestion(this.question, this.symptom);

  factory DBQuestion.fromJson(Map<String, dynamic> json) => _$DBQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$DBQuestionToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DBQuestion &&
          runtimeType == other.runtimeType &&
          question == other.question &&
          symptom == other.symptom;

  @override
  int get hashCode => question.hashCode ^ symptom.hashCode;
}