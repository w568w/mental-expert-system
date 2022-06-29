import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cool_stepper/cool_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mental_expert_system/model/question.dart';
import 'package:mental_expert_system/settings.dart';
import 'package:mental_expert_system/system/expert_system.dart';
import 'package:mental_expert_system/ui/result_page.dart';
import 'package:mental_expert_system/ui/ui_base.dart';

import 'custom_stepper.dart';

class QuestionPage extends ConsumerStatefulWidget {
  const QuestionPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _QuestionPageState();
}

class _QuestionPageState extends ConsumerState<QuestionPage> {
  late List<DBQuestion> questions;
  Map<DBQuestion, int> answers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("自我评测")),
      body: CoolStepperX(
        showErrorSnackbar: true,
        config: const CoolStepperConfig(
            nextText: "下一题", backText: "上一题", ofText: "/", stepText: "题", finalText: "完成"),
        steps: questions
            .map((e) => CoolStep(
                content: QuestionList(e, answers),
                title: e.question,
                subtitle: "请按直觉选择",
                validation: () => answers.containsKey(e) ? null : "请先选择一项！"))
            .toList(),
        onCompleted: () async {
          Map<String, List<double>> inputMap = {};
          answers.forEach((key, value) {
            if (!inputMap.containsKey(key.symptom)) {
              inputMap[key.symptom] = [];
            }
            inputMap[key.symptom]!.add((4 - value) / 4.0);
          });
          ExpertSystem system =
              await ExpertSystem.create(Settings.get().rulePath, Settings.get().symptomPath);
          var result = system.reason(inputMap.map((key, value) => MapEntry(key, value.average)));
          if (mounted) ResultPage(result).routeTo(context);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    File questionFile = File(Settings.get().questionPath);
    questions = jsonDecode(questionFile.readAsStringSync())
        .map<DBQuestion>((e) => DBQuestion.fromJson(e))
        .toList();
    questions.shuffle();
    questions = questions.take(20).toList();
  }
}

class QuestionList extends ConsumerStatefulWidget {
  final DBQuestion question;
  final Map<DBQuestion, int> answers;

  const QuestionList(
    this.question,
    this.answers, {
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _QuestionListState();
}

class _QuestionListState extends ConsumerState<QuestionList> {
  static const _answerText = ["很符合", "相当符合", "有些符合", "不太符合", "完全不符合"];

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [0, 1, 2, 3, 4]
          .map((e) => RadioListTile<int>(
              value: e,
              groupValue: widget.answers[widget.question] ?? -1,
              title: Text(_answerText[e]),
              onChanged: (value) {
                setState(() => widget.answers[widget.question] = value!);
                CoolStepperX.of(context).onStepNext();
              }))
          .toList(),
    );
  }
}
