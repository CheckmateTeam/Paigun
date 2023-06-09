import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paigun/page/components/loadingdialog.dart';
import 'package:paigun/page/components/styledialog.dart';
import 'package:paigun/provider/passenger.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';

import 'package:paigun/page/components/sizeappbar.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  String promptPayId;
  int amount;
  String journeyId;
  PaymentPage({
    Key? key,
    required this.amount,
    required this.promptPayId,
    required this.journeyId,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SizeAppbar(context, 'Payment', () => Navigator.pop(context)),
      body: Center(
        child: Column(
          children: [
            QRCodeGenerate(
              promptPayId: "0" + widget.promptPayId.substring(2),
              amount: widget.amount.toDouble(),
              width: 400,
              height: 400,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  loadingDialog(context, _isLoading, 'Checking...');
                  await context
                      .read<PassDB>()
                      .setUserRequest("pay", widget.journeyId);
                  setState(() {
                    _isLoading = false;
                  });
                  // ignore: use_build_context_synchronously
                  showDialog(
                      context: context,
                      builder: (context) {
                        return StyleDialog(context, 'Success',
                            'Please wait driver to confirm', 'Back', () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/history', (route) => false);
                        });
                      });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  'Confirm payment',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ))
          ],
        ),
      ),
    );
  }
}
