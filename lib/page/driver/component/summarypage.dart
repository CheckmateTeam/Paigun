import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SummaryPage extends StatefulWidget {
  final int receive;
  const SummaryPage({super.key, required this.receive});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 0),
                )
              ],
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppBar(
                  centerTitle: true,
                  title: Text('Summary',
                      style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor))),
            ],
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 150,
                ),
                Text('Finished',
                    style: GoogleFonts.nunito(
                        fontSize: 32, fontWeight: FontWeight.w700)),
              ],
            ),
            Column(
              children: [
                Text('You receive',
                    style: GoogleFonts.nunito(
                        fontSize: 18, fontWeight: FontWeight.w400)),
                Text((widget.receive * 0.8).round().toString() + ' Baht',
                    style: GoogleFonts.nunito(
                        fontSize: 24, fontWeight: FontWeight.w700)),
                Text(widget.receive.toString() + ' - platform service 20%',
                    style: GoogleFonts.nunito(
                        fontSize: 18, fontWeight: FontWeight.w400)),
              ],
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/driver', (route) => false);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  child: const Center(
                    child: Text(
                      'Done',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ))
          ],
        ),
      ),
    ));
  }
}
