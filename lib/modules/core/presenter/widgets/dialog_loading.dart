import 'package:flutter/material.dart';

void showLoading(BuildContext context) {
  var backgroundColor = Colors.transparent;

  showDialog(
    context: context,
    barrierColor: backgroundColor,
    builder: (_) {
      return AlertDialog(
        backgroundColor: backgroundColor,
        shadowColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        content: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}
