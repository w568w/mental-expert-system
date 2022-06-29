import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = ChangeNotifierProvider<Settings>((ref) {
  return Settings.get();
});

class Settings extends ChangeNotifier {
  SharedPreferences? preferences;
  static const _keyQuestionPath = "QUESTION_PATH";
  static const _keyRulePath = "RULE_PATH";
  static const _keySymptomPath = "SYMPTOM_PATH";
  static final Settings _instance = Settings();

  static Settings get() => _instance;

  Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  String get questionPath {
    return preferences!.getString(_keyQuestionPath) ?? r"";
  }

  String get rulePath {
    return preferences!.getString(_keyRulePath) ?? r"";
  }

  String get symptomPath {
    return preferences!.getString(_keySymptomPath) ?? r"";
  }

  set questionPath(String path) {
    preferences!.setString(_keyQuestionPath, path);
    notifyListeners();
  }

  set rulePath(String path) {
    preferences!.setString(_keyRulePath, path);
    notifyListeners();
  }

  set symptomPath(String path) {
    preferences!.setString(_keySymptomPath, path);
    notifyListeners();
  }
}
