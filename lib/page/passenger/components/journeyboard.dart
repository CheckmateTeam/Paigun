import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:paigun/provider/passenger.dart';
import 'package:provider/provider.dart';

import '../../components/sizeappbar.dart';
import 'journeyDetail.dart';

class JourneyBoard extends StatefulWidget {
  const JourneyBoard({super.key});

  @override
  State<JourneyBoard> createState() => _JourneyBoardState();
}

class _JourneyBoardState extends State<JourneyBoard> {
  TextEditingController _CurrentController = TextEditingController();
  TextEditingController _DestinationController = TextEditingController();
  TextEditingController _DateController = TextEditingController();
  DateTime _routeDate = DateTime.now();
  Map selected = {};
  List data = [];
  // List jsonData = [
  //   {"name": "Bangkok", "age": 25, "city": "New York"},
  //   {"name": "Jane", "age": 30, "city": "London"},
  //   {"name": "Tom", "age": 35, "city": "Paris"},
  //   {"name": "Emily", "age": 27, "city": "Tokyo"},
  //   {"name": "Michael", "age": 32, "city": "Berlin"}
  // ];

  // Future<void> readJson() async {
  //   setState(() async {
  //     _journey = jsonData;
  //     _showJourney = _journey;
  //   });
  // }

  List _journey = [];
  List _showJourney = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    //readJson();
    getBoard();
  }

  void getBoard() async {
    _journey = await context.read<PassDB>().getBoard();
    _showJourney = _journey;
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SizeAppbar(context, 'Journey board',
          () => Navigator.pushReplacementNamed(context, '/home')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: const EdgeInsets.all(5.0),
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      selected = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchPage()),
                      );
                      _CurrentController.text =
                          await selected['selectedProvince'];
                      setState(() {
                        _showJourney = _journey
                            .where((element) => element['origin']
                                .toString()
                                .toLowerCase()
                                .contains(
                                  _CurrentController.text.toLowerCase(),
                                ))
                            .toList();
                      });
                    },
                    controller: _CurrentController,
                    showCursor: false,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                      hintText: 'Current Location',
                      filled: true,
                      fillColor: Color.fromARGB(255, 240, 240, 240),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      prefixIcon:
                          Icon(Icons.location_pin, color: Colors.black54),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5.0),
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      selected = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchPage()),
                      );
                      _DestinationController.text =
                          selected['selectedProvince'];
                      setState(() {
                        _showJourney = _journey
                            .where((element) => element['destination']
                                .toString()
                                .toLowerCase()
                                .contains(
                                  _DestinationController.text.toLowerCase(),
                                ))
                            .toList();
                      });
                    },
                    controller: _DestinationController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                      hintText: 'Destination',
                      filled: true,
                      fillColor: Color.fromARGB(255, 240, 240, 240),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      prefixIcon: Icon(
                        Icons.location_searching,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Container(
                //   margin: const EdgeInsets.all(5.0),
                //   child: TextField(
                //     readOnly: true,
                //     controller: _DateController,
                //     onTap: () async {
                //       DateTime? selectDate = await showDatePicker(
                //           context: context,
                //           initialDate: DateTime.now(),
                //           firstDate:
                //               DateTime.now().subtract(const Duration(days: 1)),
                //           lastDate:
                //               DateTime.now().add(const Duration(days: 365)));
                //       if (selectDate != null) {
                //         // ignore: use_build_context_synchronously
                //         TimeOfDay? selectTime = await showTimePicker(
                //             context: context, initialTime: TimeOfDay.now());
                //         if (selectTime != null) {
                //           DateTime dateTime = DateTime(
                //               selectDate.year,
                //               selectDate.month,
                //               selectDate.day,
                //               selectTime.hour,
                //               selectTime.minute);
                //           _routeDate = dateTime;
                //           _DateController.text =
                //               DateFormat('E, d MMMM yyyy HH:mm a')
                //                   .format(dateTime);
                //                   print(_DateController.text);
                //         }
                //       }
                //     },
                //     showCursor: false,
                //     decoration: const InputDecoration(
                //       contentPadding: EdgeInsets.symmetric(vertical: 11),
                //       hintText: 'Date and time',
                //       filled: true,
                //       fillColor: Color.fromARGB(255, 240, 240, 240),
                //       border: OutlineInputBorder(
                //         borderSide: BorderSide.none,
                //         borderRadius: BorderRadius.all(Radius.circular(20)),
                //       ),
                //       prefixIcon:
                //           Icon(Icons.access_time_filled, color: Colors.black54),
                //     ),
                //   ),
                // ),
                Center(
                  child: ElevatedButton(
                      onPressed: () => {
                            setState(() {
                              _showJourney = _journey;
                              _CurrentController.text = '';
                              _DestinationController.text = '';
                              _DateController.text = '';
                            })
                          },
                      child: const Text("Clear filter")),
                )
              ],
            ),
            const Divider(),
            isLoading == true
                ? const SizedBox(
                    height: 400,
                    child: Center(
                      child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator()),
                    ),
                  )
                : _showJourney.isNotEmpty
                    ? Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          children: _showJourney.map((item) {
                            return GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) => JourneyDetail(
                                          origin: item['origin'],
                                          destination: item['destination'],
                                          date: item['date'],
                                          note: item['note'],
                                          profile: item['profile'],
                                        ));
                              },
                              child: Center(
                                  child: journeyTile(
                                      item['origin'],
                                      item['destination'],
                                      item['date'],
                                      item['profile']['avatar_url'])),
                            );
                          }).toList(),
                        ),
                      )
                    : const Column(
                        children: [
                          SizedBox(
                            height: 200,
                          ),
                          Center(
                            child: Text("Not found"),
                          )
                        ],
                      )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/journeyboard/create');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

Widget journeyTile(
    String origin, String destination, String date, String avatar) {
  return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 0), // Shadow position
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
              width: 50,
              height: 50,
              child: CircleAvatar(backgroundImage: NetworkImage(avatar))),
          Row(
            children: [
              const Icon(Icons.location_on_sharp),
              Expanded(
                child: Text(
                  origin,
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.flag_rounded),
              Expanded(
                child: Text(
                  destination,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            date,
            style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500]),
          ),
        ],
      ));
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // ignore: non_constant_identifier_names
  final TextEditingController _SelectedController = TextEditingController();
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/data/provinces.json');
    final data = await json.decode(response);
    setState(() {
      _province = data;
      _province = _province.map((e) {
        return e['provinceNameEn'];
      }).toList();
      _showProvince = _province;
    });
  }

  List _province = [];
  List _showProvince = [];

  @override
  void initState() {
    readJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.1,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0.8,
          bottomOpacity: 0.1,
          shadowColor: const Color.fromARGB(255, 255, 255, 255),
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          title: TextField(
            controller: _SelectedController,
            onChanged: (value) {
              setState(() {
                _showProvince = _province
                    .where((element) => element
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            },
            decoration: const InputDecoration(
              hintText: 'Find the province',
              filled: true,
              fillColor: Color.fromARGB(255, 240, 240, 240),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              prefixIcon: Icon(Icons.location_pin, color: Colors.blueAccent),
            ),
          ),
        ),
        body: Container(
          child: _showProvince.isNotEmpty
              ? ListView.builder(
                  itemCount: _showProvince.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        _SelectedController.text =
                            _showProvince[index].toString();
                        Navigator.pop(context,
                            {'selectedProvince': _SelectedController.text});
                      },
                      title: Text(_showProvince[index].toString()),
                    );
                  },
                )
              : Container(),
        ));
  }
}
