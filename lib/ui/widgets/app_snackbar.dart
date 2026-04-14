import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(milliseconds: 2800),
}) {
  final messenger = ScaffoldMessenger.of(context);
  final bottomInset = MediaQuery.of(context).padding.bottom;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(12, 0, 12, 96 + bottomInset),
        duration: duration,
        content: Text(message),
      ),
    );
}