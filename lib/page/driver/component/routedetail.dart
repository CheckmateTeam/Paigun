import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paigun/page/components/sizeappbar.dart';
import 'package:paigun/provider/userinfo.dart';
import 'package:provider/provider.dart';

class DriverRouteDetail extends StatefulWidget {
  const DriverRouteDetail({super.key, required String routeid});

  @override
  State<DriverRouteDetail> createState() => _DriverRouteDetailState();
}

class _DriverRouteDetailState extends State<DriverRouteDetail> {
  final Completer<GoogleMapController> _MapController =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];
  bool _isRequestJoinClick = false;
  bool _isRequestJoinLoading = false;

  @override
  Widget build(BuildContext context) {
    Faker faker = Faker();
    int _rating = faker.randomGenerator.integer(5);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _MapController.complete(controller);
                  },
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(13.736717, 100.523186),
                    zoom: 10,
                  ),
                  markers: _markers,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      color: Theme.of(context).primaryColor,
                      width: 5,
                      points: polylineCoordinates,
                    )
                  }),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, -5),
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'assets/images/avatarmock.png',
                                  width: 80,
                                  height: 80,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Driver name',
                                          style: GoogleFonts.nunito(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.green,
                                          size: 20,
                                        )
                                      ],
                                    ),
                                    Text(
                                      'Tel: Driver phone',
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        for (int i = 0; i < 5; i++)
                                          i < _rating
                                              ? const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 20,
                                                )
                                              : const Icon(
                                                  Icons.star,
                                                  color: Colors.grey,
                                                  size: 20,
                                                ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton.filled(
                                    style:
                                        ElevatedButton.styleFrom(elevation: 1),
                                    onPressed: () {},
                                    icon: const Icon(Icons.chat))
                              ],
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text('From',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    )),
                                Text('Bangkok',
                                    style: GoogleFonts.nunito(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Icon(
                              Icons.arrow_right_alt_rounded,
                              size: 30,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              children: [
                                Text('To',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    )),
                                Text('Chiang Mai',
                                    style: GoogleFonts.nunito(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Date and time',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    )),
                                const SizedBox(
                                  width: 3,
                                ),
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                            Text('Saturday, 20 March 2021, 10:00 AM',
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Available seats',
                                            style: GoogleFonts.nunito(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            )),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Icon(
                                          Icons.airline_seat_recline_normal,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                    Text('4',
                                        style: GoogleFonts.nunito(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Car brand',
                                            style: GoogleFonts.nunito(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            )),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Icon(
                                          Icons.car_repair_outlined,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                    Text('Honda',
                                        style: GoogleFonts.nunito(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Price per seat',
                                            style: GoogleFonts.nunito(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            )),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Icon(
                                          Icons.money_rounded,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                    Text('200 baht',
                                        style: GoogleFonts.nunito(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Model',
                                            style: GoogleFonts.nunito(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            )),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Icon(
                                          Icons.bookmark_sharp,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                    Text('Civic',
                                        style: GoogleFonts.nunito(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: () {},
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              child: Center(
                                child: const Text(
                                  'Request to join',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
                top: 20,
                left: 20,
                child: IconButton.filled(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back)))
          ],
        ),
      ),
    );
  }
}
