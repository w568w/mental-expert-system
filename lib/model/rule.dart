import 'package:json_annotation/json_annotation.dart';
import 'package:mental_expert_system/model/expression.dart';

part 'rule.g.dart';

@JsonSerializable()
class DBRule {
  final DBExpression condition;
  final DBExpression conclusion;

  DBRule(this.condition, this.conclusion);

  factory DBRule.fromJson(Map<String, dynamic> json) => _$DBRuleFromJson(json);

  Map<String, dynamic> toJson() => _$DBRuleToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DBRule &&
          runtimeType == other.runtimeType &&
          condition == other.condition &&
          conclusion == other.conclusion;

  @override
  int get hashCode => condition.hashCode ^ conclusion.hashCode;
}