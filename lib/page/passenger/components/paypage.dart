import 'dart:io';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:paigun/page/components/loadingdialog.dart';
import 'package:paigun/page/components/styledialog.dart';
import 'package:paigun/provider/passenger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';

import 'package:paigun/page/components/sizeappbar.dart';
import 'package:provider/provider.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class PaymentPage extends StatefulWidget {
  String promptPayId;
  int amount;
  Map journey;
  Map driver;
  PaymentPage({
    Key? key,
    required this.amount,
    required this.promptPayId,
    required this.journey,
    required this.driver,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  WidgetsToImageController _qrcontroller = WidgetsToImageController();
  Uint8List? bytes;
  Future<String> getImageFilePath(Uint8List imageBytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/$fileName';

    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(imageBytes);

    return imagePath;
  }

  bool _isLoading = false;
  bool _isInsurance = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SizeAppbar(context, 'Payment', () => Navigator.pop(context)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                  ),
                                ],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 224, 224, 224),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                        ),
                                      ],
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                    ),
                                    width: 70,
                                    height: 70,
                                    child: widget.driver.isEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.asset(
                                              'assets/images/avatarmock.png',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : widget.driver['avatar_url'] == ''
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: Image.asset(
                                                  'assets/images/avatarmock.png',
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: Image.network(
                                                  widget.driver['avatar_url'] ??
                                                      '',
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  },
                                                  width: 100,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            widget.driver.isEmpty
                                                ? 'Loading...'
                                                : widget.driver['full_name'] ??
                                                    '',
                                            style: GoogleFonts.nunito(
                                              fontSize: widget
                                                          .driver['full_name']
                                                          .length >
                                                      15
                                                  ? 14
                                                  : 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        widget.driver.isEmpty
                                            ? 'Loading...'
                                            : 'Tel: 0${widget.driver['username'].toString().substring(2) ?? ''}',
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton.filled(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 1),
                                      onPressed: () {},
                                      icon: const Icon(Icons.chat))
                                ],
                              )),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                      widget.journey['origin_province']
                                              .toString()
                                              .contains("Chang Wat")
                                          ? widget.journey['origin_province']
                                              .toString()
                                              .split("Chang Wat ")[1]
                                          : widget.journey['origin_province'],
                                      style: GoogleFonts.nunito(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              const Icon(
                                Icons.arrow_right_alt_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Column(
                                children: [
                                  Text(
                                      widget.journey['destination_province']
                                              .toString()
                                              .contains("Chang Wat")
                                          ? widget
                                              .journey['destination_province']
                                              .toString()
                                              .split("Chang Wat ")[1]
                                          : widget
                                              .journey['destination_province'],
                                      style: GoogleFonts.nunito(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  DateFormat("EEEE, dd MMMM yyyy")
                                      .format(DateTime.parse(
                                          widget.journey['date']))
                                      .toString(),
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        ],
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text('Price of seat',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.journey['price_seat'].toString() + ' Baht',
                            style: GoogleFonts.nunito(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Travelling insurance ( 30 Baht )',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                )),
                            Checkbox(
                                value: _isInsurance,
                                onChanged: (value) {
                                  setState(() {
                                    _isInsurance = value!;
                                  });
                                }),
                          ],
                        ),
                        Text('See details >',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_isInsurance ? widget.amount + 30 : widget.amount} Baht',
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      surfaceTintColor: Colors.white,
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      alignment: Alignment.center,
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Confirm payment',
                                            style: GoogleFonts.nunito(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          WidgetsToImage(
                                            controller: _qrcontroller,
                                            child: QRCodeGenerate(
                                              promptPayId: "0" +
                                                  widget.promptPayId
                                                      .substring(2),
                                              amount: _isInsurance
                                                  ? widget.amount +
                                                      30.toDouble()
                                                  : widget.amount.toDouble(),
                                              width: 400,
                                              height: 400,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {},
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                            ),
                                            onPressed: () async {
                                              final bytes =
                                                  await _qrcontroller.capture();
                                              File imgfile = File.fromRawPath(
                                                  bytes!.buffer.asUint8List());
                                              String imgpath =
                                                  await getImageFilePath(
                                                      bytes,
                                                      'QRcode' +
                                                          widget.journey[
                                                                  'journey_id']
                                                              .toString() +
                                                          '.png');

                                              GallerySaver.saveImage(imgpath)
                                                  .then((value) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Saved to gallery')));
                                              });
                                            },
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 40,
                                                        vertical: 10),
                                                child: const Text(
                                                  'Save QR Code',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: Text('Pay now',
                                style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)))),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    surfaceTintColor: Colors.white,
                                    actionsAlignment: MainAxisAlignment.center,
                                    alignment: Alignment.center,
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Confirm payment?',
                                          style: GoogleFonts.nunito(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    content:
                                        Text('You won\'t be able to pay later',
                                            style: GoogleFonts.nunito(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            )),
                                    actions: [
                                      Column(
                                        children: [
                                          TextButton(
                                            onPressed: () async {},
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                loadingDialog(context,
                                                    _isLoading, 'Checking...');
                                                await context
                                                    .read<PassDB>()
                                                    .setUserRequest(
                                                        "pay",
                                                        widget.journey[
                                                            'journey_id']);
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                                // ignore: use_build_context_synchronously
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return StyleDialog(
                                                          context,
                                                          'Success',
                                                          'You are now on the journey',
                                                          'Back', () {
                                                        Navigator
                                                            .pushNamedAndRemoveUntil(
                                                                context,
                                                                '/history',
                                                                (route) =>
                                                                    false);
                                                      });
                                                    });
                                              },
                                              child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 40,
                                                      vertical: 10),
                                                  child: const Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              loadingDialog(context, _isLoading,
                                                  'Checking...');
                                              await context
                                                  .read<PassDB>()
                                                  .setUserRequest(
                                                      "pay",
                                                      widget.journey[
                                                          'journey_id']);
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              // ignore: use_build_context_synchronously
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return StyleDialog(
                                                        context,
                                                        'Success',
                                                        'Please wait driver to confirm',
                                                        'Back', () {
                                                      Navigator
                                                          .pushNamedAndRemoveUntil(
                                                              context,
                                                              '/history',
                                                              (route) => false);
                                                    });
                                                  });
                                            },
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 40,
                                                      vertical: 10),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2),
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(
                            'Confirm payment',
                            style: GoogleFonts.nunito(
                                color: Theme.of(context).primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
