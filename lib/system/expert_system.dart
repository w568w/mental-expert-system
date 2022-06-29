import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:mental_expert_system/model/expression.dart';
import 'package:mental_expert_system/model/symptom.dart';
import 'package:mental_expert_system/model/rule.dart';

class ExpertSystem {
  final List<DBRule> rules;
  final List<DBSymptom> symptomHierarchy;

  Map<String, LinearFunction> diseaseCompositeFunctions = {};

  ExpertSystem._(this.rules, this.symptomHierarchy) {
    // 初始化病症列表
    for (var rule in rules) {
      rule.conclusion.walkThrough((expression) {
        if (expression.type == DBExpression.typeOr) {
          throw ArgumentError.value(rules, "规则后项不应包含 OR 运算符。", "Rules");
        } else if (expression.type == DBExpression.typeRule) {
          diseaseCompositeFunctions[expression.variable!] = LinearFunction();
        }
      });
    }
  }

  /// 根据输入 [input] 进行推理，返回各疾病的可信度。
  Map<String, double> reason(Map<String, double> input) {
    List<Symptom> symptomInput = [];
    // 统计输入
    for (var superSymptom in symptomHierarchy) {
      double subSymptomSum = 0;
      for (var subSymptom in superSymptom.symptom) {
        double subInput = input[subSymptom] ?? 0;
        symptomInput.add(Symptom(subSymptom, false, subInput));
        subSymptomSum += subInput;
      }
      int subSymptomNum = superSymptom.symptom.length;
      symptomInput.add(Symptom(
          superSymptom.superSymptom, true, subSymptomNum == 0 ? 0 : subSymptomSum / subSymptomNum));
    }
    for (var rule in rules) {
      // 规则评估
      double trueValue = rule.condition.evaluate(symptomInput);
      // 聚合规则的输出
      rule.conclusion.walkThrough((expression) {
        if (expression.type == DBExpression.typeRule) {
          var originalFunc = diseaseCompositeFunctions[expression.variable!];
          if (originalFunc != null) {
            diseaseCompositeFunctions[expression.variable!] =
                originalFunc + LinearFunction.fromFuzzySet(expression.modifier!) * trueValue;
          }
        }
      });
    }
    // 逆模糊化
    return diseaseCompositeFunctions.map((key, value) => MapEntry(key, value.weight()));
  }

  static Future<ExpertSystem> create(String rulePath, String symptomHierarchyPath) async {
    var ruleFile = File(rulePath);
    List<dynamic> rules = jsonDecode(await ruleFile.readAsString());
    var symFile = File(symptomHierarchyPath);
    List<dynamic> syms = jsonDecode(await symFile.readAsString());
    return ExpertSystem._(rules.map((e) => DBRule.fromJson(e)).toList(),
        syms.map((e) => DBSymptom.fromJson(e)).toList());
  }
}

class Symptom {
  final String name;
  final bool isFirstClass;
  final double input;

  Symptom(this.name, this.isFirstClass, this.input);

  @override
  String toString() {
    return 'Symptom{name: $name, isFirstClass: $isFirstClass, input: $input}';
  }
}

class LinearFunction {
  static final Map<int, LinearFunction> _defaultLevelFunction = {
    0: LinearFunction.copy({0: 1, 0.25: 0}),
    1: LinearFunction.copy({0.2: 0, 0.3: 1, 0.4: 1, 0.5: 0}),
    2: LinearFunction.copy({0.3: 0, 0.4: 1, 0.6: 1, 0.7: 0}),
    3: LinearFunction.copy({0.5: 0, 0.6: 1, 0.7: 1, 0.8: 0}),
    4: LinearFunction.copy({0.75: 0, 1: 1})
  };
  late final Map<double, double> segmentPoints;

  @override
  String toString() {
    return 'LinearFunction{segmentPoints: $segmentPoints}';
  }

  LinearFunction() {
    segmentPoints = {};
  }

  LinearFunction.copy(Map<double, double> segmentPoints) {
    this.segmentPoints = Map.from(segmentPoints);
  }

  double call(double input) {
    if (segmentPoints.isEmpty) {
      return 0;
    }
    if (segmentPoints.length == 1) {
      return segmentPoints.values.first;
    }
    var sortedKeyPoints = segmentPoints.keys.sorted((a, b) => a.compareTo(b));
    for (int i = 0; i < sortedKeyPoints.length - 1; i++) {
      double a = segmentPoints[sortedKeyPoints[i]]!, b = segmentPoints[sortedKeyPoints[i + 1]]!;
      if (sortedKeyPoints[i] <= input && sortedKeyPoints[i + 1] > input) {
        return (input - sortedKeyPoints[i]) /
                (sortedKeyPoints[i + 1] - sortedKeyPoints[i]) *
                (b - a) +
            a;
      }
    }
    if (input <= sortedKeyPoints.first) {
      return segmentPoints[sortedKeyPoints.first]!;
    }
    if (input >= sortedKeyPoints.last) {
      return segmentPoints[sortedKeyPoints.last]!;
    }
    return 0;
  }

  double weight() {
    if (segmentPoints.isEmpty) {
      throw UnsupportedError("Cannot calculate the weight of a zero function");
    }
    double axisWeight = 0;
    double areaSize = 0;

    var copiedPoints = Map.from(segmentPoints);
    var sortedKeyPoints = copiedPoints.keys.sorted((a, b) => a.compareTo(b));
    if (sortedKeyPoints.first != 0) {
      copiedPoints[0] = copiedPoints[sortedKeyPoints.first]!;
      sortedKeyPoints.insert(0, copiedPoints[0]!);
    }
    if (sortedKeyPoints.last != 1) {
      copiedPoints[1] = copiedPoints[sortedKeyPoints.last]!;
      sortedKeyPoints.insert(sortedKeyPoints.length, copiedPoints[1]!);
    }
    // 计算分子 ∫ f(s)s ds 和分母 ∫ f(s) ds
    for (int i = 0; i < sortedKeyPoints.length - 1; i++) {
      double x1 = sortedKeyPoints[i], x2 = sortedKeyPoints[i + 1];
      double y1 = copiedPoints[x1]!, y2 = copiedPoints[x2]!;
      double k = (y2 - y1) / (x2 - x1);
      axisWeight +=
          k / 3 * (x2 * x2 * x2 - x1 * x1 * x1) + 1 / 2 * (y1 - k * x1) * (x2 * x2 - x1 * x1);
      areaSize += (y1 + y2) * (x2 - x1) / 2;
    }
    return axisWeight / areaSize;
  }

  LinearFunction operator *(double multiplier) {
    LinearFunction newFunction = LinearFunction.copy(segmentPoints);
    newFunction.segmentPoints.updateAll((key, value) => value * multiplier);
    return newFunction;
  }

  LinearFunction operator +(LinearFunction function) {
    LinearFunction newFunction = LinearFunction();
    for (var key in [...function.segmentPoints.keys, ...segmentPoints.keys]) {
      newFunction.segmentPoints[key] = function.call(key) + call(key);
      print("$key: ${call(key)} ${function.call(key)}");
    }
    return newFunction;
  }

  LinearFunction very() {
    if (segmentPoints.length < 2) throw UnsupportedError("信息不足，无法求 very");
    LinearFunction newFunction = LinearFunction.copy(segmentPoints);
    var sortedKeyPoints = segmentPoints.keys.sorted((a, b) => a.compareTo(b));
    if (segmentPoints.length == 2) {
      if (segmentPoints[sortedKeyPoints.first]! > segmentPoints[sortedKeyPoints.last]!) {
        newFunction.segmentPoints[(sortedKeyPoints.first + sortedKeyPoints.last) / 2] =
            newFunction.segmentPoints.remove(sortedKeyPoints.last)!;
      } else {
        newFunction.segmentPoints[(sortedKeyPoints.first + sortedKeyPoints.last) / 2] =
            newFunction.segmentPoints.remove(sortedKeyPoints.first)!;
      }
    } else {
      newFunction.segmentPoints[(sortedKeyPoints[0] + sortedKeyPoints[1]) / 2] =
          newFunction.segmentPoints.remove(sortedKeyPoints[0])!;
      newFunction.segmentPoints[
              (sortedKeyPoints[sortedKeyPoints.length - 2] + sortedKeyPoints.last) / 2] =
          newFunction.segmentPoints.remove(sortedKeyPoints.last)!;
    }
    return newFunction;
  }

  LinearFunction not() {
    LinearFunction newFunction = LinearFunction.copy(segmentPoints);
    newFunction.segmentPoints.updateAll((key, value) => 1 - value);
    return newFunction;
  }

  factory LinearFunction.fromFuzzySet(DBFuzzySet set) {
    LinearFunction function = _defaultLevelFunction[set.level]!;
    if (set.very) function = function.very();
    if (set.not) function = function.not();
    return function;
  }
}

extension on DBExpression {
  void walkThrough(void Function(DBExpression expression) visitor) {
    visitor(this);
    switch (type) {
      case DBExpression.typeRule:
        break;
      case DBExpression.typeAnd:
      case DBExpression.typeOr:
        first!.walkThrough(visitor);
        second!.walkThrough(visitor);
    }
  }

  double evaluate(List<Symptom> input) {
    switch (type) {
      case DBExpression.typeRule:
        Symptom sym = input.findSymptomByName(variable!);
        return LinearFunction.fromFuzzySet(modifier!).call(sym.input);
      case DBExpression.typeAnd:
        return min(first!.evaluate(input), second!.evaluate(input));
      case DBExpression.typeOr:
        return max(first!.evaluate(input), second!.evaluate(input));
      default:
        return 0;
    }
  }
}

extension on List<Symptom> {
  Symptom findSymptomByName(String name) => firstWhere((element) => element.name == name);
}
