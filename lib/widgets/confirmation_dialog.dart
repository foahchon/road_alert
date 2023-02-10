import 'package:flutter/material.dart';

class ConfirmationDialog {
  final String title;
  final String prompt;
  final String yesText;
  final String noText;

  const ConfirmationDialog(
      {required this.title,
      required this.prompt,
      this.yesText = 'Yes',
      this.noText = 'No'});

  Future<bool> getConfirmation(BuildContext context) async {
    var yesButton = TextButton(
      child: Text(yesText),
      onPressed: () => Navigator.of(context).pop(true),
    );
    var noButton = TextButton(
      child: Text(noText),
      onPressed: () => Navigator.of(context).pop(false),
    );

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(prompt),
        actions: [noButton, yesButton],
      ),
    );
  }
}
