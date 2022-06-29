import 'package:flutter/material.dart';

extension PageEx on Widget {
  void routeTo(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (cxt) => this));
  }
}
