import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_expert_system/model/expression.dart';
import 'package:mental_expert_system/model/question.dart';
import 'package:mental_expert_system/model/rule.dart';
import 'package:mental_expert_system/model/symptom.dart';
import 'package:mental_expert_system/noticing.dart';
import 'package:mental_expert_system/settings.dart';

class EditPage extends ConsumerWidget {
  const EditPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("编辑"),
            bottom: const TabBar(
              tabs: [
                Tab(child: Text("症状分类")),
                Tab(child: Text("自评量表问题库")),
                Tab(child: Text("知识规则")),
              ],
            ),
          ),
          body: const TabBarView(children: [SymptomEdit(), QuestionEdit(), RuleEdit()]),
        ),
      );
}

class SymptomEdit extends ConsumerStatefulWidget {
  const SymptomEdit({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SymptomEditState();
}

class _SymptomEditState extends ConsumerState<SymptomEdit> {
  late File symptomFile;

  void writeBack(List<DBSymptom> symptoms) => symptomFile.writeAsStringSync(jsonEncode(symptoms));

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: ref
          .watch(symptomsProvider)
          .map((sym) => GestureDetector(
                onLongPress: () => showModalBottomSheet(
                    context: context,
                    builder: (cxt) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text("删除本项"),
                              onTap: () {
                                Navigator.of(context).pop();
                                ref.read(symptomsProvider.notifier).update((state) {
                                  state.remove(sym);
                                  writeBack(state);
                                  return [...state];
                                });
                              },
                            ),
                            ListTile(
                              title: const Text("增加同级项"),
                              onTap: () async {
                                Navigator.of(context).pop();
                                var result = await Noticing.showInputDialog(context, "输入新的一级症状名");
                                if (result != null &&
                                    result.isNotEmpty &&
                                    !ref
                                        .read(symptomsProvider)
                                        .any((element) => element.superSymptom == result)) {
                                  ref.read(symptomsProvider.notifier).update((state) {
                                    state.add(DBSymptom(result, []));
                                    writeBack(state);
                                    return [...state];
                                  });
                                }
                              },
                            ),
                            ListTile(
                              title: const Text("增加下级项"),
                              onTap: () async {
                                Navigator.of(context).pop();
                                var result = await Noticing.showInputDialog(context, "输入新的二级症状名");
                                if (result != null &&
                                    result.isNotEmpty &&
                                    !sym.symptom.any((element) => element == result)) {
                                  ref.read(symptomsProvider.notifier).update((state) {
                                    sym.symptom.add(result);
                                    writeBack(state);
                                    return [...state];
                                  });
                                }
                              },
                            )
                          ],
                        )),
                child: ExpansionTile(
                    title: Text(sym.superSymptom),
                    children: sym.symptom
                        .map((subsym) => ListTile(
                              title: Text(subsym),
                              onLongPress: () async {
                                var result = await Noticing.showConfirmationDialog(
                                    context, "是否删除本项？",
                                    isConfirmDestructive: true);
                                if (result == true) {
                                  ref.read(symptomsProvider.notifier).update((state) {
                                    sym.symptom.remove(subsym);
                                    writeBack(state);
                                    return [...state];
                                  });
                                }
                              },
                            ))
                        .toList()),
              ))
          .toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    symptomFile = File(Settings.get().symptomPath);
    symptomFile.createSync(recursive: true);
    symptomFile.readAsString().then((value) {
      ref.read(symptomsProvider.notifier).state =
          jsonDecode(value).map<DBSymptom>((e) => DBSymptom.fromJson(e)).toList();
    });
  }
}

class QuestionEdit extends ConsumerStatefulWidget {
  const QuestionEdit({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _QuestionEditState();
}

class _QuestionEditState extends ConsumerState<QuestionEdit> {
  late File questionFile;

  void writeBack(List<DBQuestion> questions) =>
      questionFile.writeAsStringSync(jsonEncode(questions));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: ref
            .watch(questionsProvider)
            .map((e) => ListTile(
                  title: Text(e.question),
                  subtitle: Text(e.symptom),
                  onLongPress: () async {
                    var result = await Noticing.showConfirmationDialog(context, "是否删除本项？",
                        isConfirmDestructive: true);
                    if (result == true) {
                      ref.read(questionsProvider.notifier).update((state) {
                        state.remove(e);
                        writeBack(state);
                        return [...state];
                      });
                    }
                  },
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (cxt) {
                TextEditingController controller = TextEditingController();
                List<String> subSymptoms = [];
                String? selectSymptom;
                for (var sym in ref.read(symptomsProvider)) {
                  subSymptoms.addAll(sym.symptom);
                }
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: "问题"),
                      ),
                      StatefulBuilder(
                        builder: (_, refreshState) => DropdownButton(
                            hint: const Text("选择一个对应症状"),
                            value: selectSymptom,
                            items: subSymptoms
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (String? str) => refreshState(() => selectSymptom = str)),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(cxt).pop();
                          if (selectSymptom == null ||
                              selectSymptom!.isEmpty ||
                              controller.text.isEmpty) return;
                          ref.read(questionsProvider.notifier).update((state) {
                            state.add(DBQuestion(controller.text, selectSymptom!));
                            writeBack(state);
                            return [...state];
                          });
                        },
                        child: const Text("插入"))
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    questionFile = File(Settings.get().questionPath);
    questionFile.createSync(recursive: true);
    questionFile.readAsString().then((value) {
      ref.read(questionsProvider.notifier).state =
          jsonDecode(value).map<DBQuestion>((e) => DBQuestion.fromJson(e)).toList();
    });
  }
}

class RuleEdit extends ConsumerStatefulWidget {
  const RuleEdit({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _RuleEditState();
}

class _RuleEditState extends ConsumerState<RuleEdit> {
  late File ruleFile;

  void writeBack(List<DBRule> questions) => ruleFile.writeAsStringSync(jsonEncode(questions));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: ref
            .watch(rulesProvider)
            .map((e) => InkWell(
                  onLongPress: () async {
                    var result = await Noticing.showConfirmationDialog(context, "是否删除本项？",
                        isConfirmDestructive: true);
                    if (result == true) {
                      ref.read(rulesProvider.notifier).update((state) {
                        state.remove(e);
                        writeBack(state);
                        return [...state];
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(e.condition.toString()),
                        const Icon(Icons.arrow_right_alt),
                        Text(e.conclusion.toString())
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (cxt) {
                TextEditingController conditionController = TextEditingController();
                TextEditingController conclusionController = TextEditingController();
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                          controller: conditionController,
                          decoration: const InputDecoration(hintText: "前提")),
                      TextField(
                          controller: conclusionController,
                          decoration: const InputDecoration(hintText: "推论")),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          if (conditionController.text.isEmpty ||
                              conclusionController.text.isEmpty) {
                            return;
                          }
                          ref.read(rulesProvider.notifier).update((state) {
                            try {
                              state.add(DBRule(DBExpression.fromString(conditionController.text),
                                  DBExpression.fromString(conclusionController.text)));
                            } catch (e) {
                              Noticing.showErrorDialog(context, e);
                              return state;
                            }
                            writeBack(state);
                            Navigator.of(cxt).pop();
                            return [...state];
                          });
                        },
                        child: const Text("插入"))
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    ruleFile = File(Settings.get().rulePath);
    ruleFile.createSync(recursive: true);
    ruleFile.readAsString().then((value) {
      ref.read(rulesProvider.notifier).state =
          jsonDecode(value).map<DBRule>((e) => DBRule.fromJson(e)).toList();
    });
  }
}

final symptomsProvider = StateProvider<List<DBSymptom>>((ref) => []);
final questionsProvider = StateProvider<List<DBQuestion>>((ref) => []);
final rulesProvider = StateProvider<List<DBRule>>((ref) => []);
