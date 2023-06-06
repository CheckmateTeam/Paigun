import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget StyleDialog(BuildContext context, String title, String content,
    String buttontext, Function onPressed) {
  return AlertDialog(
    actionsAlignment: MainAxisAlignment.center,
    alignment: Alignment.center,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(content),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {},
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {
            onPressed();
          },
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                buttontext,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
        ),
      ),
    ],
  );
}
