// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:paigun/model/journey_model.dart';
import 'package:paigun/page/components/loadingdialog.dart';
import 'package:paigun/page/components/sizeappbar.dart';
import 'package:paigun/provider/driver.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';

import '../../../provider/passenger.dart';

class CreateRoute extends StatefulWidget {
  const CreateRoute({super.key});

  @override
  State<CreateRoute> createState() => _CreateRouteState();
}

class _CreateRouteState extends State<CreateRoute> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: SizeAppbar(
                context, 'Create Route', () => Navigator.pop(context)),
            body: const Padding(
              padding: EdgeInsets.all(20.0),
              child: RouteMap(),
            )));
  }
}

class RouteMap extends StatefulWidget {
  const RouteMap({super.key});

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _MapController =
      Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];
  TextEditingController _FromController = TextEditingController();
  String _FromFull = '';
  String _FromPlace = '';
  LatLng _FromPosition = const LatLng(0, 0);
  TextEditingController _ToController = TextEditingController();
  String _ToFull = '';
  LatLng _ToPosition = const LatLng(0, 0);
  String _ToPlace = '';
  TextEditingController _DateController = TextEditingController();
  DateTime _routeDate = DateTime.now();
  TextEditingController _AvailableController = TextEditingController();
  TextEditingController _PriceController = TextEditingController();
  TextEditingController _CarbrandController = TextEditingController();
  TextEditingController _CarmodelController = TextEditingController();
  TextEditingController _NoteController = TextEditingController();
  bool _submitLoading = false;
  bool _createLoading = false;

  void createRoutePoint() async {
    PolylinePoints polylinePoints = PolylinePoints();
    if (_FromController.text.isNotEmpty && _ToController.text.isNotEmpty) {
      if (polylineCoordinates.isNotEmpty) {
        polylineCoordinates.clear();
        _markers.clear();
      }

      _markers.add(Marker(
          markerId: const MarkerId('From'),
          position: _FromPosition,
          infoWindow: InfoWindow(title: _FromFull, snippet: _FromPlace)));
      _markers.add(Marker(
          markerId: const MarkerId('To'),
          position: _ToPosition,
          infoWindow: InfoWindow(title: _ToFull, snippet: _ToPlace)));
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
          50));
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LatLng currentPosition = Provider.of<PassDB>(context).currentPosition;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            height: MediaQuery.of(context).size.height * 0.24,
            width: MediaQuery.of(context).size.width,
            child: AbsorbPointer(
              child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _MapController.complete(controller);
                  },
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: currentPosition,
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
            )),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        controller: _FromController,
                        onTap: () async {
                          LocationResult result = await Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => PlacePicker(
                                        dotenv.env['GOOGLEMAP_KEY'] ?? '',
                                        displayLocation: currentPosition,
                                      )));

                          //location pick
                          _FromController.text = result.name.toString().length >
                                  10
                              ? '${result.name.toString().substring(0, 10)}...'
                              : result.name.toString();
                          String province =
                              result.city.toString() == 'Krung Thep Maha Nakhon'
                                  ? 'Bangkok'
                                  : result.city.toString();
                          LatLng latLng = result.latLng ?? currentPosition;
                          _markers.add(
                            Marker(
                              markerId: const MarkerId('from'),
                              position: latLng,
                              infoWindow: InfoWindow(
                                  title: _FromController.text,
                                  snippet: province),
                              icon: BitmapDescriptor.defaultMarker,
                            ),
                          );
                          _FromFull = result.name.toString();
                          _FromPosition = latLng;
                          _FromPlace = province;
                          createRoutePoint();
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
                        onTap: () async {
                          LocationResult result = await Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => PlacePicker(
                                        dotenv.env['GOOGLEMAP_KEY'] ?? '',
                                        displayLocation: currentPosition,
                                      )));

                          //location pick
                          _ToController.text = result.name.toString().length > 8
                              ? '${result.name.toString().substring(0, 8)}...'
                              : result.name.toString();
                          String province =
                              result.city.toString() == 'Krung Thep Maha Nakhon'
                                  ? 'Bangkok'
                                  : result.city.toString();
                          LatLng latLng0 = result.latLng ?? currentPosition;
                          _ToFull = result.name.toString();
                          _ToPosition = latLng0;
                          _ToPlace = province;
                          _markers.add(
                            Marker(
                              markerId: const MarkerId('to'),
                              position: latLng0,
                              infoWindow: InfoWindow(
                                  title: _ToController.text, snippet: province),
                              icon: BitmapDescriptor.defaultMarker,
                            ),
                          );
                          createRoutePoint();
                        },
                        readOnly: true,
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
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 45,
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
                            final res = await Navigator.of(context).push(
                              showPicker(
                                context: context,
                                value: Time(
                                    hour: TimeOfDay.now().hour,
                                    minute: TimeOfDay.now().minute),
                                onChange: (value) {},
                              ),
                            );

                            TimeOfDay? selectTime = res as TimeOfDay?;
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
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 45,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _AvailableController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Available Seats',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon:
                              Icon(Icons.airline_seat_recline_normal_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _PriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Price per seat',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 45,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _CarbrandController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Car brand',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Icon(Icons.minor_crash_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _CarmodelController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Car model',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Icon(Icons.no_crash_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
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
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_FromController.text.isEmpty ||
                      _ToController.text.isEmpty ||
                      _DateController.text.isEmpty ||
                      _AvailableController.text.isEmpty ||
                      _PriceController.text.isEmpty ||
                      _CarbrandController.text.isEmpty ||
                      _CarmodelController.text.isEmpty ||
                      _NoteController.text.isEmpty) {
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
                              'Confirm create route',
                            ),
                            content: Text(
                                "Would you like to create route from $_FromFull to $_ToFull at ${_DateController.text}"),
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
                                        'Creating route...');
                                    List<Placemark> fromAddress =
                                        await placemarkFromCoordinates(
                                            _FromPosition.latitude,
                                            _FromPosition.longitude);
                                    List<Placemark> toAddress =
                                        await placemarkFromCoordinates(
                                            _ToPosition.latitude,
                                            _ToPosition.longitude);
                                    String fromProvince = "";
                                    String toProvince = "";
                                    if (fromAddress[0].administrativeArea! ==
                                        'Krung Thep Maha Nakhon') {
                                      fromProvince = 'Bangkok';
                                    } else {
                                      fromProvince =
                                          fromAddress[0].administrativeArea!;
                                    }

                                    if (toAddress[0].administrativeArea! ==
                                        'Krung Thep Maha Nakhon') {
                                      toProvince = 'Bangkok';
                                    } else {
                                      toProvince =
                                          toAddress[0].administrativeArea!;
                                    }
                                    //Delete chang Wat
                                    toProvince.contains('Chang Wat')
                                        ? toProvince = toProvince.replaceAll(
                                            'Chang Wat ', '')
                                        : toProvince = toProvince;
                                    fromProvince.contains('Chang Wat')
                                        ? fromProvince = fromProvince
                                            .replaceAll('Chang Wat ', '')
                                        : fromProvince = fromProvince;

                                    var res = await Provider.of<DriveDB>(
                                            context,
                                            listen: false)
                                        .CreateRoute(Journey(
                                            start: _FromPosition,
                                            end: _ToPosition,
                                            startProvince: fromProvince,
                                            endProvince: toProvince,
                                            time: _routeDate,
                                            seat: _AvailableController.text,
                                            price: _PriceController.text,
                                            carBrand: _CarbrandController.text,
                                            carModel: _CarmodelController.text,
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
                                                              '/driver');
                                                    },
                                                    child: const Text(
                                                        'Back to home')),
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
          ),
        ),
      ],
    );
  }
}
