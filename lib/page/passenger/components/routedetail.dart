// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:paigun/page/components/loadingdialog.dart';

import 'package:paigun/page/components/styledialog.dart';
import 'package:paigun/page/passenger/components/paypage.dart';
import 'package:paigun/provider/passenger.dart';
import 'package:provider/provider.dart';

class RouteDetail extends StatefulWidget {
  final Map driver;
  final Map info;
  final String status;
  const RouteDetail({
    Key? key,
    required this.driver,
    required this.info,
    required this.status,
  }) : super(key: key);

  @override
  State<RouteDetail> createState() => _RouteDetailState();
}

class _RouteDetailState extends State<RouteDetail> {
  final Completer<GoogleMapController> _MapController =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];
  bool _profileLoading = false;
  bool _isLoading = false;
  bool _isRequest = false;
  bool _isDriverConfirm = false;
  bool _isPay = false;
  bool _isComplete = false;
  Map _driverProfile = {};
  void createRoutePoint() async {
    PolylinePoints polylinePoints = PolylinePoints();

    LatLng _FromPosition = LatLng(double.parse(widget.info['origin_lat']),
        double.parse(widget.info['origin_lng']));
    LatLng _ToPosition = LatLng(double.parse(widget.info['destination_lat']),
        double.parse(widget.info['destination_lng']));

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

  void getStatus() async {
    // print(widget.status);
    if (widget.status == 'pending') {
      setState(() {
        _isRequest = true;
      });
    } else if (widget.status == 'paid') {
      setState(() {
        _isRequest = true;
        _isPay = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStatus();
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
                                              ),
                                            ),
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
                                          widget.driver.isEmpty
                                              ? 'Loading...'
                                              : widget.driver['full_name'] ??
                                                  '',
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
                                      widget.driver.isEmpty
                                          ? 'Loading...'
                                          : 'Tel: 0${widget.driver['username'].toString().substring(2) ?? ''}',
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
                                Text(
                                    widget.info['origin_province']
                                            .toString()
                                            .contains("Chang Wat")
                                        ? widget.info['origin_province']
                                            .toString()
                                            .split("Chang Wat ")[1]
                                        : widget.info['origin_province'],
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
                                Text(
                                    widget.info['destination_province']
                                            .toString()
                                            .contains("Chang Wat")
                                        ? widget.info['destination_province']
                                            .toString()
                                            .split("Chang Wat ")[1]
                                        : widget.info['destination_province'],
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
                            Text(
                                DateFormat("EEEE, dd MMMM yyyy, HH:mm")
                                    .format(DateTime.parse(widget.info['date']))
                                    .toString(),
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
                                    Text(
                                        widget.info['available_seat']
                                            .toString(),
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
                                    Text(widget.info['car_brand'],
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
                                    Text(widget.info['price_seat'].toString(),
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
                                    Text(widget.info['car_model'],
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
                            ? _isPay
                                ? _isDriverConfirm
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
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                        ),
                                        onPressed: () {},
                                        child: Container(
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          height: 50,
                                          child:
                                              Text('Waiting for driver confirm',
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  )),
                                        ))
                                : Column(
                                    children: [
                                      Text('Please paid to confirm your seat.',
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
                                                    BorderRadius.circular(15)),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PaymentPage(
                                                          amount: widget.info[
                                                              'price_seat'],
                                                          promptPayId:
                                                              widget.driver[
                                                                  'username'],
                                                          journeyId:
                                                              widget.info[
                                                                  'journey_id'],
                                                        )));
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            alignment: Alignment.center,
                                            height: 50,
                                            child: Text('Pay now',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                )),
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
                                                    color: Colors.redAccent,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Cancle Request'),
                                                    content: const Text(
                                                        'Are you sure you want to cancel request to join this trip?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            const Text('Back'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          setState(() {
                                                            _isLoading = true;
                                                          });
                                                          loadingDialog(
                                                              context,
                                                              _isLoading,
                                                              'Sending request...');
                                                          await context
                                                              .read<PassDB>()
                                                              .setUserRequest(
                                                                "cancel",
                                                                widget.info[
                                                                    'journey_id'],
                                                              );
                                                          setState(() {
                                                            _isLoading = false;
                                                            _isRequest = false;
                                                          });
                                                          // ignore: use_build_context_synchronously
                                                          await showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return StyleDialog(
                                                                    context,
                                                                    'Cancle Succes',
                                                                    'You have cancel request to join this trip.',
                                                                    'Done', () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
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
                                            alignment: Alignment.center,
                                            height: 50,
                                            child: Text('Cancel request',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.redAccent,
                                                )),
                                          )),
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
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                loadingDialog(
                                                    context,
                                                    _isLoading,
                                                    'Sending request...');
                                                await context
                                                    .read<PassDB>()
                                                    .setUserRequest(
                                                      "join",
                                                      widget.info['journey_id'],
                                                    );
                                                setState(() {
                                                  _isRequest = true;
                                                  _isLoading = false;
                                                });
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
