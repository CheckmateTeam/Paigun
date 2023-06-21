import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:paigun/model/board_model.dart';
import 'package:paigun/provider/passenger.dart';
import 'package:provider/provider.dart';

import '../../components/loadingdialog.dart';
import '../../components/sizeappbar.dart';
import 'journeyboard.dart';

class CreateJourney extends StatefulWidget {
  const CreateJourney({super.key});

  @override
  State<CreateJourney> createState() => _CreateJourneyState();
}

class _CreateJourneyState extends State<CreateJourney> {
  TextEditingController _DateController = TextEditingController();
  TextEditingController _FromController = TextEditingController();
  TextEditingController _ToController = TextEditingController();
  TextEditingController _NoteController = TextEditingController();
  bool _submitLoading = false;
  bool _createLoading = false;
  DateTime _routeDate = DateTime.now();
  Map selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          SizeAppbar(context, 'Create journey', () => Navigator.pop(context)),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _FromController,
                        readOnly: true,
                        onTap: () async {
                          selected = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchPage()),
                          );
                          _FromController.text = selected['selectedProvince'];
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'From',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Icon(Icons.my_location_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _ToController,
                        readOnly: true,
                        onTap: () async {
                          selected = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchPage()),
                          );
                          _ToController.text = selected['selectedProvince'];
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'To',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onTap: () async {
                          DateTime? selectDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 1)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)));
                          if (selectDate != null) {
                            // ignore: use_build_context_synchronously
                            TimeOfDay? selectTime = await showTimePicker(
                                context: context, initialTime: TimeOfDay.now());
                            if (selectTime != null) {
                              DateTime dateTime = DateTime(
                                  selectDate.year,
                                  selectDate.month,
                                  selectDate.day,
                                  selectTime.hour,
                                  selectTime.minute);
                              _routeDate = dateTime;
                              _DateController.text =
                                  DateFormat('E, d MMMM yyyy HH:mm a')
                                      .format(dateTime);
                            }
                          }
                        },
                        controller: _DateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Date and Time',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 70,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _NoteController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Note',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Icon(Icons.note_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_FromController.text.isEmpty ||
                      _ToController.text.isEmpty ||
                      _DateController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all field')));
                    return;
                  }
                  setState(() {
                    _submitLoading = true;
                  });
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text(
                              'Confirm create journey',
                            ),
                            content: Text(
                                "Would you like to create a journey from ${_FromController.text} to ${_ToController.text} at ${_DateController.text} ?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _submitLoading = false;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      _createLoading = true;
                                    });
                                    loadingDialog(context, _createLoading,
                                        'Creating journey...');

                                    var res = await Provider.of<PassDB>(context,
                                            listen: false)
                                        .createBoard(Board(
                                            date: _DateController.text,
                                            origin: _FromController.text,
                                            destination: _ToController.text,
                                            note: _NoteController.text));
                                    setState(() {
                                      _createLoading = false;
                                      _submitLoading = false;
                                    });

                                    if (res == null) {
                                      // ignore: use_build_context_synchronously
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                icon: Image.asset(
                                                    'assets/images/marker2.png',
                                                    width: 100,
                                                    height: 100),
                                                title: const Text('Oops!'),
                                                actionsAlignment:
                                                    MainAxisAlignment.center,
                                                alignment: Alignment.center,
                                                content: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text('Create route failed'),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                          'Back to create route')),
                                                ],
                                              ));
                                      return;
                                    }
                                    // ignore: use_build_context_synchronously
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AlertDialog(
                                              icon: Image.asset(
                                                  'assets/images/marker2.png',
                                                  width: 100,
                                                  height: 100),
                                              title: const Text('Hooray!'),
                                              actionsAlignment:
                                                  MainAxisAlignment.center,
                                              alignment: Alignment.center,
                                              content: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text('Create route success'),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator
                                                          .pushReplacementNamed(
                                                              context,
                                                              '/journeyboard');
                                                    },
                                                    child: const Text('Done')),
                                              ],
                                            ));
                                  },
                                  child: const Text('Confirm')),
                            ],
                          ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _submitLoading
                    ? const SpinKitFadingCube(
                        color: Colors.white,
                        size: 20,
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          )),
    );
  }
}
