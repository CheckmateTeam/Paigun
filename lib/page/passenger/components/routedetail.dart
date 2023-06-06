import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paigun/page/components/sizeappbar.dart';
import 'package:paigun/page/components/styledialog.dart';
import 'package:paigun/provider/userinfo.dart';
import 'package:provider/provider.dart';

class RouteDetail extends StatefulWidget {
  const RouteDetail({super.key, required String routeid});

  @override
  State<RouteDetail> createState() => _RouteDetailState();
}

class _RouteDetailState extends State<RouteDetail> {
  final Completer<GoogleMapController> _MapController =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];
  bool _isRequest = false;
  bool _isDriverConfirm = false;
  bool _isPay = false;
  bool _isComplete = false;

  void createRoutePoint() async {
    PolylinePoints polylinePoints = PolylinePoints();

    LatLng _FromPosition = const LatLng(13.736717, 100.523186);
    LatLng _ToPosition = const LatLng(20.736717, 105.523186);

    _markers.add(Marker(
      markerId: const MarkerId('From'),
      position: _FromPosition,
    ));
    _markers.add(Marker(
      markerId: const MarkerId('To'),
      position: _ToPosition,
    ));
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      dotenv.env['GOOGLEMAP_KEY'] ?? '',
      PointLatLng(_FromPosition.latitude, _FromPosition.longitude),
      PointLatLng(_ToPosition.latitude, _ToPosition.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    GoogleMapController controller = await _MapController.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
              _FromPosition.latitude < _ToPosition.latitude
                  ? _FromPosition.latitude
                  : _ToPosition.latitude,
              _FromPosition.longitude < _ToPosition.longitude
                  ? _FromPosition.longitude
                  : _ToPosition.longitude),
          northeast: LatLng(
              _FromPosition.latitude > _ToPosition.latitude
                  ? _FromPosition.latitude
                  : _ToPosition.latitude,
              _FromPosition.longitude > _ToPosition.longitude
                  ? _FromPosition.longitude
                  : _ToPosition.longitude),
        ),
        80));
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createRoutePoint();
  }

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
                            const Icon(
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
                        _isRequest
                            ? _isDriverConfirm
                                ? _isPay
                                    ? _isComplete
                                        ? Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                  ),
                                                  onPressed: () {
                                                    print("Go to report page");
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    alignment: Alignment.center,
                                                    height: 50,
                                                    child: Text(
                                                        'Complete Route',
                                                        style:
                                                            GoogleFonts.nunito(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        )),
                                                  )),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .redAccent,
                                                                width: 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15)),
                                                  ),
                                                  onPressed: () {},
                                                  child: Container(
                                                    width: double.infinity,
                                                    alignment: Alignment.center,
                                                    height: 50,
                                                    child: Text('Cancel Route',
                                                        style:
                                                            GoogleFonts.nunito(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.redAccent,
                                                        )),
                                                  )),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )
                                    : Column(
                                        children: [
                                          Text(
                                              'Please paid to confirm your seat.',
                                              style: GoogleFonts.nunito(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.redAccent,
                                              )),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                              ),
                                              onPressed: () {},
                                              child: Container(
                                                width: double.infinity,
                                                alignment: Alignment.center,
                                                height: 50,
                                                child: Text('Pay now',
                                                    style: GoogleFonts.nunito(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    )),
                                              )),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      )
                                : Column(
                                    children: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: Colors.redAccent,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                          ),
                                          onPressed: () {},
                                          child: Container(
                                            width: double.infinity,
                                            alignment: Alignment.center,
                                            height: 50,
                                            child: Text('Cancel request',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.redAccent,
                                                )),
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  )
                            :
                            //Request to join button
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Request to join'),
                                          content: const Text(
                                              'Are you sure you want to request to join this trip?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                // await Future.delayed(
                                                //     const Duration(seconds: 2), () {

                                                // });

                                                // ignore: use_build_context_synchronously
                                                await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return StyleDialog(
                                                          context,
                                                          'Request sent',
                                                          'You will get a notification when the driver accepts your request',
                                                          'Done', () {
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      });
                                                    });
                                              },
                                              child: Text('Confirm'),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(15),
                                  child: const Center(
                                    child: Text(
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
