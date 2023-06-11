// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:bottom_sheet_scaffold/bottom_sheet_scaffold.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:paigun/page/components/loadingdialog.dart';
import 'package:paigun/page/components/styledialog.dart';
import 'package:paigun/provider/driver.dart';
import 'package:provider/provider.dart';

class DriverRouteDetail extends StatefulWidget {
  final Map driver;
  final List passenger;
  final Map info;
  final String status;
  const DriverRouteDetail({
    Key? key,
    required this.driver,
    required this.passenger,
    required this.info,
    required this.status,
  }) : super(key: key);

  @override
  State<DriverRouteDetail> createState() => _DriverRouteDetailState();
}

class _DriverRouteDetailState extends State<DriverRouteDetail> {
  final Completer<GoogleMapController> _MapController =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];
  bool _isStart = false;
  bool _isLoading = false;
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
    if (widget.status == "going") {
      _isStart = true;
    } else {
      _isStart = false;
    }
  }

  void openMapLauncher(map_launcher.Coords coord) async {
    try {
      const title = "Destination";
      final availableMaps = await map_launcher.MapLauncher.installedMaps;

      // ignore: use_build_context_synchronously
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Wrap(
                children: <Widget>[
                  for (var map in availableMaps)
                    ListTile(
                      onTap: () => map.showMarker(
                        coords: coord,
                        title: title,
                        extraParams: {
                          "travelmode": "driving",
                          "dir_action": "navigate"
                        },
                      ),
                      title: Text(map.mapName),
                      leading: SvgPicture.asset(
                        map.icon,
                        height: 30.0,
                        width: 30.0,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
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
      child: BottomSheetScaffold(
        draggableBody: false,
        dismissOnClick: true,
        bottomSheet: DraggableBottomSheet(
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView.builder(
                itemCount: widget.passenger.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        child: ListTile(
                          leading: Container(
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
                            width: 60,
                            child: widget.passenger[index]['user_id']
                                        ['avatar_url'] ==
                                    ''
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.asset(
                                      'assets/images/avatarmock.png',
                                      width: 80,
                                      height: 80,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      widget.passenger[index]['user_id']
                                          ['avatar_url'],
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.passenger[index]['user_id']
                                        ['full_name'],
                                    style: GoogleFonts.nunito(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "0${widget.passenger[index]['user_id']['username'].toString().substring(2)}",
                                    style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                'Verified',
                                style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.verified, color: Colors.green),
                            ],
                          ),
                          trailing: IconButton.filled(
                              style: ElevatedButton.styleFrom(elevation: 1),
                              onPressed: () {},
                              icon: const Icon(Icons.mail_rounded,
                                  color: Colors.white)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                }),
          ),
          header: Container(
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
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            height: 100,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.drag_handle_outlined,
                    color: Colors.black,
                  ),
                  Text(
                    "Current passengers",
                    style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
          ),
        ),
        body: Stack(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
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
                    zoom: 15.00,
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
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _isStart
                            ? Column(
                                children: [
                                  ElevatedButton(
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
                                        padding: const EdgeInsets.all(15),
                                        child: Center(
                                          child: Text(
                                            'Completed',
                                            style: GoogleFonts.nunito(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor:
                                            Color.fromARGB(255, 179, 179, 179),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                      ),
                                      onPressed: () {
                                        openMapLauncher(map_launcher.Coords(
                                            double.parse(
                                                widget.info['destination_lat']),
                                            double.parse(widget
                                                .info['destination_lng'])));
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(15),
                                        child: Center(
                                          child: Text(
                                            'Open Map',
                                            style: GoogleFonts.nunito(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )),
                                ],
                              )
                            : Column(
                                children: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Start Route?'),
                                                content: const Text(
                                                    'Are you sure you want to start this trip?'),
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
                                                          'Starting...');
                                                      final res = await context
                                                          .read<DriveDB>()
                                                          .changeJourneyStatus(
                                                              widget.info[
                                                                  'journey_id'],
                                                              'going');
                                                      setState(() {
                                                        _isStart = true;
                                                      });
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child:
                                                        const Text('Confirm'),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(15),
                                        child: Center(
                                          child: Text(
                                            'Start route',
                                            style: GoogleFonts.nunito(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                                color: Colors.redAccent,
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Cancel Route?'),
                                                content: const Text(
                                                    'Are you sure you want to cancle this trip?'),
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
                                                          'Cancelling...');
                                                      final res = await context
                                                          .read<DriveDB>()
                                                          .deleteRoute(widget
                                                                  .info[
                                                              'journey_id']);
                                                      setState(() {
                                                        _isStart = true;
                                                      });
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return StyleDialog(
                                                                context,
                                                                'Remove success!',
                                                                'You will be redirect to home screen',
                                                                'Go', () {
                                                              Navigator
                                                                  .pushNamedAndRemoveUntil(
                                                                      context,
                                                                      '/home',
                                                                      (route) =>
                                                                          false);
                                                            });
                                                          });
                                                    },
                                                    child: const Text(
                                                      'Confirm',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.redAccent),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(15),
                                        child: Center(
                                          child: Text(
                                            'Cancel route',
                                            style: GoogleFonts.nunito(
                                                color: Colors.redAccent,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )),
                                ],
                              ),
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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(),
                            SizedBox(
                              height: 60,
                            ),
                          ],
                        ),
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
