/*
 *     Copyright (C) 2021  DanXi-Dev
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Simple helper class to show a notice,
/// like [SnackBar] on Material or a [CupertinoAlertDialog] on Cupertino.
class Noticing {
  static Future<String?> showInputDialog(BuildContext context, String title,
      {String? confirmText,
      bool isConfirmDestructive = false,
      int? maxLines,
      String? hintText}) async {
    TextEditingController controller = TextEditingController();
    String? value = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hintText),
          maxLines: maxLines,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: <Widget>[
          TextButton(child: const Text("取消"), onPressed: () => Navigator.pop(context, null)),
          TextButton(
              style: isConfirmDestructive
                  ? ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.red))
                  : null,
              child: Text(confirmText ?? "确认"),
              onPressed: () => Navigator.pop(context, controller.text)),
        ],
      ),
    );
    // We won't dispose the controller, as it is only used in an anonymous function
    //  rather than a [StatefulWidget]. So, it is unnecessary to release the resource.
    //  (and at the time, [TextEditingController.dispose] only does debug and assertion work.)
    // controller.dispose();
    return value;
  }

//
  static Future<bool?> showConfirmationDialog(BuildContext context, String message,
      {String? confirmText,
      String? cancelText,
      String? title,
      bool isConfirmDestructive = false}) async {
    return await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: title == null ? null : Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                    child: Text(cancelText ?? "取消"),
                    onPressed: () => Navigator.pop(context, false)),
                TextButton(
                    style: isConfirmDestructive
                        ? ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.red))
                        : null,
                    child: Text(confirmText ?? "确定"),
                    onPressed: () => Navigator.pop(context, true)),
              ],
            ));
  }

  static showErrorDialog(BuildContext context, dynamic error,
      {StackTrace? trace, String? title}) async {
    title ??= "错误";
    return await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: title == null ? null : Text(title),
              content: Text(error.toString()),
              actions: <Widget>[
                TextButton(child: const Text("好"), onPressed: () => Navigator.pop(context)),
              ],
            ));
  }
//
// static showModalNotice(BuildContext context,
//     {String title = "", String message = "", bool selectable = false}) async {
//   if (!title.endsWith('\n') && !message.startsWith('\n')) title += '\n';
//   Widget content = Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: SingleChildScrollView(
//         child: ListTile(
//             title: Text(title),
//             subtitle: selectable
//                 ? SelectableLinkify(text: message)
//                 : Linkify(text: message))),
//   );
//   Widget body;
//   if (PlatformX.isCupertino(context)) {
//     body = SafeArea(
//       child: Card(
//         child: content,
//       ),
//     );
//   } else {
//     body = SafeArea(
//       child: content,
//     );
//   }
//   showPlatformModalSheet(
//     context: context,
//     builder: (BuildContext context) => body,
//   );
// }
}

class CustomDialogActionItem {
  final String text;
  final VoidCallback onPressed;

  CustomDialogActionItem(this.text, this.onPressed);
}
