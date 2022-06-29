
import 'package:json_annotation/json_annotation.dart';
import 'package:petitparser/parser.dart';

part 'expression.g.dart';

@JsonSerializable()
class DBExpression {
  static const typeRule = 0;
  static const typeAnd = 1;
  static const typeOr = 2;

  // 0:标准; 1:And; 2:Or
  final int type;
  final DBExpression? first;
  final DBExpression? second;

  // 语言变量。可以是二级症状或病症
  final String? variable;

  final DBFuzzySet? modifier;

  DBExpression(this.type, this.first, this.second, this.variable, this.modifier)
      : assert((type == DBExpression.typeRule && variable != null && modifier != null) ||
            (type != DBExpression.typeRule && first != null && second != null));

  factory DBExpression.fromJson(Map<String, dynamic> json) => _$DBExpressionFromJson(json);

  factory DBExpression.fromString(String expression) {
    Parser characterNormal() => pattern('^"\\ ()');
    Parser characterUnicode() => string('\\u') & pattern('0-9A-Fa-f').times(4);
    final prim = undefined();
    final term = undefined();
    final variable = (characterNormal() | characterUnicode()).plus();
    final number = digit().flatten().trim().map(int.parse);
    final singleStatement = (variable &
            string("is").trim() &
            (string("very") | string("not")).trim().optional() &
            number)
        .map((value) => DBExpression(DBExpression.typeRule, null, null, value[0].join(),
            DBFuzzySet(value[3], value[2] == "very", value[2] == "not")));
    final parens = (char('(').trim() & term & char(')').trim()).map((value) => value[1]);
    final statement = (prim & (string("and") | string("or")).trim() & term).map((value) =>
        DBExpression(value[1] == "and" ? DBExpression.typeAnd : DBExpression.typeOr, value[0],
            value[2], null, null));
    prim.set(parens | singleStatement);
    term.set(statement | prim);
    final parser = term.end();
    return parser.parse(expression).value;
  }

  Map<String, dynamic> toJson() => _$DBExpressionToJson(this);

  @override
  String toString() {
    switch (type) {
      case DBExpression.typeRule:
        return "($variable is${modifier!.very ? " very" : ""}${modifier!.not ? " not" : ""} ${modifier!.level})";
      case DBExpression.typeOr:
        return "(${first!} or ${second!})";
      case DBExpression.typeAnd:
        return "(${first!} and ${second!})";
    }
    return "";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DBExpression &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          first == other.first &&
          second == other.second &&
          variable == other.variable &&
          modifier == other.modifier;

  @override
  int get hashCode =>
      type.hashCode ^ first.hashCode ^ second.hashCode ^ variable.hashCode ^ modifier.hashCode;
}

@JsonSerializable()
class DBFuzzySet {
  // 程度，0~4 为 very low~very high
  final int level;

  // 限定词
  final bool very;
  final bool not;

  DBFuzzySet(this.level, this.very, this.not);

  factory DBFuzzySet.fromJson(Map<String, dynamic> json) => _$DBFuzzySetFromJson(json);

  Map<String, dynamic> toJson() => _$DBFuzzySetToJson(this);

  @override
  String toString() {
    return 'DBFuzzySet{level: $level, very: $very, not: $not}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DBFuzzySet &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          very == other.very &&
          not == other.not;

  @override
  int get hashCode => level.hashCode ^ very.hashCode ^ not.hashCode;
}
