import 'package:flutter/material.dart';

void loadingDialog(BuildContext context, bool condition, String message) {
  showDialog(
      context: context,
      builder: (context) {
        condition ? null : Navigator.of(context).pop();
        return AlertDialog(
          alignment: Alignment.center,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message),
            ],
          ),
          content: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: 50, width: 50, child: CircularProgressIndicator()),
            ],
          ),
        );
      },
      barrierDismissible: false);
}
