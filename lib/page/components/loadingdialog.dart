import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: 50,
                  width: 50,
                  child: SpinKitFadingCube(
                      size: 25, color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        );
      },
      barrierDismissible: false);
}
