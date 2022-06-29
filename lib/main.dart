import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_expert_system/model/expression.dart';
import 'package:mental_expert_system/settings.dart';
import 'package:mental_expert_system/ui/edit_page.dart';
import 'package:mental_expert_system/ui/question_page.dart';
import 'package:mental_expert_system/ui/settings_page.dart';
import 'package:mental_expert_system/ui/ui_base.dart';

void main() {
  DBExpression.fromString("(中国 is not 0) and (美国 is very 1) or (日本 is 2)");
  Settings.get().init().then((_) => runApp(const ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Mental diagnostic system',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: const TextTheme(
              bodyText1: TextStyle(fontWeight: FontWeight.w400),
              bodyText2: TextStyle(fontWeight: FontWeight.w400),
              button: TextStyle(fontWeight: FontWeight.w400),
              overline: TextStyle(fontWeight: FontWeight.w400),
              headline1: TextStyle(fontWeight: FontWeight.w400),
              headline2: TextStyle(fontWeight: FontWeight.w400),
              headline3: TextStyle(fontWeight: FontWeight.w400),
              caption: TextStyle(fontWeight: FontWeight.w400),
              headline4: TextStyle(fontWeight: FontWeight.w400),
              headline5: TextStyle(fontWeight: FontWeight.w400),
              headline6: TextStyle(fontWeight: FontWeight.w400),
          )),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  static get dataPrepared =>
      Settings.get().symptomPath.isNotEmpty &&
      Settings.get().rulePath.isNotEmpty &&
      Settings.get().questionPath.isNotEmpty;

  bool ensureDataPrepared(BuildContext context) {
    if (!dataPrepared) {
      showDialog(
          context: context,
          builder: (cxt) => AlertDialog(
                title: const Text("错误"),
                content: const Text("还未设置合理的知识库路径，请先在右上角选项中进行设置！"),
                actions: [TextButton(onPressed: Navigator.of(cxt).pop, child: const Text("确定"))],
              ));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("心理诊断系统"),
        actions: [
          IconButton(
              onPressed: () => const SettingsPage().routeTo(context),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () {
                  if (ensureDataPrepared(context)) const QuestionPage().routeTo(context);
                },
                child: const Text("我是受试者")),
            ElevatedButton(
                onPressed: () {
                  if (ensureDataPrepared(context)) const EditPage().routeTo(context);
                },
                child: const Text("我是专家"))
          ],
        ),
      ),
    );
  }
}
