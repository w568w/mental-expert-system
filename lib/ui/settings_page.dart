import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_expert_system/settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({
    Key? key,
  }) : super(key: key);

  Future<void> selectPathAndSet(void Function(String path) pathSetter) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      pathSetter(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var setting = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("应用程序设置"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("症状分类库"),
            subtitle: Text(setting.symptomPath),
            onTap: () => selectPathAndSet((path) => setting.symptomPath = path),
          ),
          ListTile(
            title: const Text("自评量表问题库"),
            subtitle: Text(setting.questionPath),
            onTap: () => selectPathAndSet((path) => setting.questionPath = path),
          ),
          ListTile(
            title: const Text("知识规则库"),
            subtitle: Text(setting.rulePath),
            onTap: () => selectPathAndSet((path) => setting.rulePath = path),
          ),
        ],
      ),
    );
  }
}
