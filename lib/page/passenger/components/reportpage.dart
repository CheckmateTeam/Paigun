// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:paigun/page/components/loadingdialog.dart';
import 'package:paigun/page/components/sizeappbar.dart';
import 'package:paigun/page/components/styledialog.dart';
import 'package:paigun/provider/passenger.dart';
import 'package:provider/provider.dart';

class ReportPage extends StatefulWidget {
  final Map driver;
  final Map info;
  const ReportPage({
    Key? key,
    required this.driver,
    required this.info,
  }) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _multiSelectKey = GlobalKey<FormFieldState>();
  double _rating = 0;
  bool _isLoading = false;
  List _reportString = [
    'Driver was late',
    'Driver was speeding',
    'Driver was smoking',
    'Driver was drunk',
  ];
  List<String> _reportList = [];
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: SizeAppbar(context, 'Rating', () => Navigator.pop(context)),
            body: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Report button + driver
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 20),
                                  elevation: 1,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 189, 189, 189),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled:
                                        true, // required for min/max child size
                                    context: context,
                                    builder: (ctx) {
                                      return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: MultiSelectBottomSheet(
                                            items: _reportString
                                                .map((e) =>
                                                    MultiSelectItem(e, e))
                                                .toList(),
                                            initialValue: _reportString
                                                .sublist(0, 0)
                                                .toList(),
                                            onConfirm: (values) {
                                              setState(() {
                                                _reportList.clear();
                                                _reportList.addAll(values
                                                    .map((e) => e.toString())
                                                    .toList());
                                              });
                                            },
                                            maxChildSize: 0.8,
                                          ));
                                    },
                                  );
                                },
                                child: const Text(
                                  'Report',
                                  style: TextStyle(color: Colors.red),
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //driver
                        Container(
                            padding: const EdgeInsets.all(20),
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  width: 80,
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
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
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
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.driver.isEmpty
                                          ? 'Loading...'
                                          : widget.driver['full_name'] ?? '',
                                      style: GoogleFonts.nunito(
                                        fontSize:
                                            widget.driver['full_name'].length >
                                                    15
                                                ? 16
                                                : 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Verified',
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.green,
                                          size: 20,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 30,
                                )
                              ],
                            )),
                      ],
                    ),
                    //Rating
                    Column(
                      children: [
                        Text('How was the journey?',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        RatingBar.builder(
                          initialRating: 3,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            print(rating);
                            setState(() {
                              _rating = rating;
                            });
                          },
                        )
                      ],
                    ),
                    //comment
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Comment',
                            style: GoogleFonts.nunito(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(
                          child: TextField(
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            controller: _controller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  left: 20, top: 20, bottom: 100, right: 20),
                              hintText: 'Type your comment here',
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                          ),
                        )
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
                          setState(() {
                            _isLoading = true;
                          });
                          loadingDialog(context, _isLoading, 'Sending review');
                          await context.read<PassDB>().passengerFinishJourney(
                              widget.info['journey_id'],
                              _controller.text,
                              widget.driver['id'],
                              _rating,
                              _reportList);
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (context) {
                                return StyleDialog(context, 'Finish',
                                    'You have finish this journey', 'OK', () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/history', (route) => false);
                                });
                              });
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
                ))));
  }
}
