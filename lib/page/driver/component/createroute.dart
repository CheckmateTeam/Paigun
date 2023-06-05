import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paigun/page/components/sizeappbar.dart';
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

class _RouteMapState extends State<RouteMap> {
  final Completer<GoogleMapController> _MapController =
      Completer<GoogleMapController>();

  TextEditingController _FromController = TextEditingController();
  TextEditingController _ToController = TextEditingController();
  TextEditingController _DateController = TextEditingController();
  TextEditingController _AvailableController = TextEditingController();
  TextEditingController _PriceController = TextEditingController();
  TextEditingController _CarbrandController = TextEditingController();
  TextEditingController _CarmodelController = TextEditingController();
  TextEditingController _NoteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    LatLng _currentPosition = Provider.of<PassDB>(context).currentPosition;
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
            child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _MapController.complete(controller);
                },
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 10,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('current'),
                    position: _currentPosition,
                  )
                },
                polylines: {
                  const Polyline(
                    polylineId: PolylineId('route'),
                  )
                })),
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
                                        displayLocation: _currentPosition,
                                      )));

                          //location pick
                          _FromController.text =
                              result.formattedAddress.toString().length > 10
                                  ? result.formattedAddress
                                          .toString()
                                          .substring(0, 10) +
                                      '...'
                                  : result.formattedAddress.toString();
                          String _province =
                              result.city.toString() == 'Krung Thep Maha Nakhon'
                                  ? 'Bangkok'
                                  : result.city.toString();
                          LatLng _latLng = result.latLng ?? _currentPosition;
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
                                        displayLocation: _currentPosition,
                                      )));

                          //location pick
                          _ToController.text =
                              result.formattedAddress.toString().length > 10
                                  ? result.formattedAddress
                                          .toString()
                                          .substring(0, 10) +
                                      '...'
                                  : result.formattedAddress.toString();
                          String _province =
                              result.city.toString() == 'Krung Thep Maha Nakhon'
                                  ? 'Bangkok'
                                  : result.city.toString();
                          LatLng _latLng = result.latLng ?? _currentPosition;
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
                onPressed: () {},
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
