// ignore_for_file: use_build_context_synchronously

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:paigun/page/components/loading_placeholder.dart';
import 'package:paigun/page/components/loadingdialog.dart';
import 'package:paigun/page/components/sizeappbar.dart';
import 'package:paigun/page/components/styledialog.dart';
import 'package:paigun/page/driver/component/routedetail.dart';
import 'package:paigun/page/passenger/components/routedetail.dart';
import 'package:paigun/provider/driver.dart';
import 'package:paigun/provider/passenger.dart';
import 'package:paigun/provider/userinfo.dart';
import 'package:provider/provider.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  bool _isLoading = false;
  bool _profileLoading = false;
  void _fetchInfo() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<DriveDB>().getDriverJourney();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SizeAppbar(context, 'Driver Mode',
          () => Navigator.pushReplacementNamed(context, '/home')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const LoadingPlaceholder()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (context.read<DriveDB>().request == 0) {
                              showDialog(
                                  context: context,
                                  builder: (context) => StyleDialog(
                                      context,
                                      'No request',
                                      'There is no request yet',
                                      'OK',
                                      () => Navigator.pop(context)));
                            } else {
                              Navigator.pushNamed(context, '/driver/request');
                            }
                          },
                          child: Text(
                            'New ${context.watch<DriveDB>().request} join request',
                            style: GoogleFonts.nunito(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor),
                          ))),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'On open',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600]),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                        itemCount: context
                            .watch<DriveDB>()
                            .driverJourney
                            .where((e) {
                              return e['status'] == 'available';
                            })
                            .toList()
                            .length,
                        itemBuilder: (context, index) => GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _profileLoading = true;
                                });
                                loadingDialog(
                                    context, _profileLoading, 'Loading...');
                                final res = await Provider.of<UserInfo>(context,
                                        listen: false)
                                    .userinfo;

                                final String status =
                                    await Provider.of<DriveDB>(context,
                                            listen: false)
                                        .getDriverJourneyStatus(context
                                            .read<DriveDB>()
                                            .driverJourney
                                            .where((e) {
                                  return e['status'] == 'available';
                                }).toList()[index]['journey_id']);
                                List passenger = await Provider.of<DriveDB>(
                                        context,
                                        listen: false)
                                    .getJourneyPassenger(context
                                        .read<DriveDB>()
                                        .driverJourney
                                        .where((e) {
                                  return e['status'] == 'available';
                                }).toList()[index]['journey_id']);
                                setState(() {
                                  _profileLoading = false;
                                });
                                Navigator.pop(context);
                                print(res);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return DriverRouteDetail(
                                    driver: res,
                                    passenger: passenger,
                                    info: context
                                        .read<DriveDB>()
                                        .driverJourney
                                        .where((e) {
                                      return e['status'] == 'available';
                                    }).toList()[index],
                                    status: status,
                                  );
                                }));
                              },
                              child: journeyTile(
                                  context
                                      .read<DriveDB>()
                                      .driverJourney
                                      .where((e) {
                                    return e['status'] == 'available';
                                  }).toList()[index]['origin_province'],
                                  context
                                      .read<DriveDB>()
                                      .driverJourney
                                      .where((e) {
                                    return e['status'] == 'available';
                                  }).toList()[index]['destination_province'],
                                  DateFormat('dd/MM/yyyy hh:mm a').format(
                                      DateTime.parse(context
                                          .read<DriveDB>()
                                          .driverJourney
                                          .where((e) {
                                    return e['status'] == 'available';
                                  }).toList()[index]['date'])),
                                  'open',
                                  context),
                            )),
                  ),
                  Text(
                    'Closed',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600]),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                        itemCount: context
                            .watch<DriveDB>()
                            .driverJourney
                            .where((e) {
                              return e['status'] == 'done';
                            })
                            .toList()
                            .length,
                        itemBuilder: (context, index) => journeyTile(
                            context.read<DriveDB>().driverJourney.where((e) {
                              return e['status'] == 'done';
                            }).toList()[index]['origin_province'],
                            context.read<DriveDB>().driverJourney.where((e) {
                              return e['status'] == 'done';
                            }).toList()[index]['destination_province'],
                            DateFormat('EEEE, dd MMMM yyyy').format(
                                DateTime.parse(context
                                    .read<DriveDB>()
                                    .driverJourney
                                    .where((e) {
                              return e['status'] == 'done';
                            }).toList()[index]['date'])),
                            'done',
                            context)),
                  ),
                ],
              ),
      ),
    );
  }
}

Widget journeyTile(String origin, String destination, String date,
    String status, BuildContext context) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color.fromARGB(255, 238, 238, 238), width: 0.8)),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(
              Icons.location_on_outlined,
              color: Colors.white,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_sharp),
                  Text(
                    origin,
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800]),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.flag_rounded),
                  Text(
                    destination,
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800]),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Text(
            date,
            style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500]),
          ),
        ),
      ),
      const SizedBox(
        height: 10,
      )
    ],
  );
}
