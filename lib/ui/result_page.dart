import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResultPage extends ConsumerWidget {
  final Map<String, double> result;

  const ResultPage(
    this.result, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    result.removeWhere((key, value) => !value.isFinite);
    return Scaffold(
      appBar: AppBar(
        title: const Text("诊断结果"),
      ),
      body: ListView(
          children: result.keys
              .map((e) => ListTile(title: Text(e), subtitle: Text("确信度：${result[e]}")))
              .toList()),
    );
  }
}
