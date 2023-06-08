// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:faker/faker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:paigun/page/components/loadingdialog.dart';
import 'package:paigun/page/passenger/components/drawer.dart';
import 'package:paigun/page/passenger/components/routedetail.dart';
import 'package:paigun/provider/passenger.dart';
import 'package:paigun/provider/userinfo.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../../function/show_snackbar.dart';
import 'components/searchLocation.dart';

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final ScrollController _myScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map destination = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var faker = Faker();
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          drawer: const HomeDrawer(),
          body: SnappingSheet(
            lockOverflowDrag: true,
            snappingPositions: const [
              SnappingPosition.factor(
                positionFactor: 0.0,
                snappingCurve: Curves.easeOutExpo,
                snappingDuration: Duration(seconds: 1),
                grabbingContentOffset: GrabbingContentOffset.top,
              ),
              SnappingPosition.factor(
                positionFactor: 0.4,
                snappingCurve: Curves.easeInOut,
                snappingDuration: Duration(seconds: 1),
                grabbingContentOffset: GrabbingContentOffset.bottom,
              ),
              SnappingPosition.factor(
                positionFactor: 1.0,
                snappingCurve: Curves.easeInOut,
                snappingDuration: Duration(seconds: 1),
                grabbingContentOffset: GrabbingContentOffset.bottom,
              ),
            ],
            grabbingHeight: MediaQuery.of(context).size.height * 0.1,
            grabbing: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.drag_handle_rounded,
                          color: Colors.black45, size: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.12,
                            ),
                            Text(
                              'Nearby routes',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.12,
                              child: FloatingActionButton(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white,
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/driver/create');
                                },
                                child: Icon(
                                  Icons.add_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            sheetBelow: SnappingSheetContent(
              draggable: true,
              child: ListView(
                reverse: false,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                      itemCount: context.watch<PassDB>().journey.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return RouteDetail(
                                      driverid: context
                                          .read<PassDB>()
                                          .journey[index]['owner'],
                                      info:
                                          context.read<PassDB>().journey[index],
                                    );
                                  }));
                                },
                                leading: const Icon(Icons.call_split_rounded),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      context
                                              .read<PassDB>()
                                              .journey[index]['origin_province']
                                              .toString()
                                              .contains('Chang Wat')
                                          ? context
                                              .read<PassDB>()
                                              .journey[index]['origin_province']
                                              .toString()
                                              .split("Chang Wat ")[1]
                                          : context
                                              .read<PassDB>()
                                              .journey[index]['origin_province']
                                              .toString(),
                                      style: GoogleFonts.nunito(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Icon(Icons.arrow_right_alt_rounded,
                                        color: Colors.black),
                                    Text(
                                      context
                                              .read<PassDB>()
                                              .journey[index]
                                                  ['destination_province']
                                              .toString()
                                              .contains('Chang Wat')
                                          ? context
                                              .read<PassDB>()
                                              .journey[index]
                                                  ['destination_province']
                                              .toString()
                                              .split("Chang Wat ")[1]
                                          : context
                                              .read<PassDB>()
                                              .journey[index]
                                                  ['destination_province']
                                              .toString(),
                                      style: GoogleFonts.nunito(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Center(
                                  child: Text(
                                    DateFormat('dd/MM/yyyy hh:mm a').format(
                                        DateTime.parse(context
                                            .read<PassDB>()
                                            .journey[index]['date'])),
                                    style: GoogleFonts.nunito(
                                      color:
                                          ui.Color.fromARGB(255, 138, 138, 138),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                              )),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            //Content behind snapping sheet
            child: Stack(children: <Widget>[
              //MAP
              const MapComponent(),
              //SEARCH BAR
              Positioned(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                          onPressed: () {
                            _scaffoldKey.currentState!.openDrawer();
                          },
                          icon: const Icon(
                            Icons.menu,
                            size: 40,
                          )),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 60,
                        child: TextField(
                          controller: _searchController,
                          showCursor: false,
                          readOnly: true,
                          onTap: () async {
                            destination = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchPage()),
                            );
                            print(destination['Current'] +
                                ' ' +
                                destination['Destination']);
                            _searchController.text = destination['Destination'];
                            if (destination['Current'] != '' &&
                                destination['Destination'] != '') {
                              setState(() {
                                _isSearching = true;
                              });
                              loadingDialog(context, _isSearching, 'Searching');
                              final res = await context
                                  .read<PassDB>()
                                  .getJourneyByProvince(destination['Current'],
                                      destination['Destination']);
                              if (res == null) {
                                setState(() {
                                  _isSearching = false;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'No available journey for this route'),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _isSearching = false;
                                });
                                Navigator.pop(context);
                              }
                            } else {
                              setState(() {
                                _isSearching = true;
                              });
                              loadingDialog(context, _isSearching, 'Searching');
                              final res =
                                  await context.read<PassDB>().getJourney(1000);
                              Navigator.pop(context);
                            }
                          },
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            hintText: 'Where to go?',
                            hintStyle: GoogleFonts.nunito(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            floatingLabelAlignment:
                                FloatingLabelAlignment.center,
                            border: InputBorder.none,
                            filled: true,
                            suffixIcon: const Icon(Icons.search),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ]),
          )),
    );
  }
}

class MapComponent extends StatefulWidget {
  const MapComponent({super.key});

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  final Completer<GoogleMapController> _MapController =
      Completer<GoogleMapController>();
  String _currentAddress = 'Unknown';
  LatLng _currentLocation = const LatLng(0, 0);
  BitmapDescriptor markerIcon1 = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIcon2 = BitmapDescriptor.defaultMarker;
  String _GpsError = '';
  MapType _currentMapType = MapType.normal;

  void _addCustomMarker1() async {
    final ByteData bytes = await rootBundle.load('assets/images/marker1.png');
    final Uint8List list = bytes.buffer.asUint8List();
    final ui.Codec codec =
        await ui.instantiateImageCodec(list, targetWidth: 100);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    markerIcon1 = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  void _addCustomMarker2() async {
    final ByteData bytes = await rootBundle.load('assets/images/marker2.png');
    final Uint8List list = bytes.buffer.asUint8List();
    final ui.Codec codec =
        await ui.instantiateImageCodec(list, targetWidth: 100);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    markerIcon2 = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  //location tracking
  void _determinePosition() async {
    bool serviceEnabled;
    PermissionStatus permission;
    Location location = Location();
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _GpsError = 'Please enable GPS';
        return;
      }
    }

    permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        _GpsError = 'Please allow GPS permission';
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      if (mounted) {
        super.setState(() {
          _currentLocation = LatLng(
              currentLocation.latitude ?? 0, currentLocation.longitude ?? 0);
          Provider.of<PassDB>(context, listen: false)
              .updatePosition(_currentLocation);
        });
      }
    });
  }

  Future<void> _goToCurrent() async {
    final GoogleMapController controller = await _MapController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _currentLocation,
        zoom: 15,
      ),
    ));
  }

  Future<void> _changeTerrain() async {
    final GoogleMapController controller = await _MapController.future;
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else
        _currentMapType = MapType.normal;
    });
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _currentLocation,
        zoom: 16,
      ),
    ));
  }

  Future<void> _fetchRoute() async {
    await Provider.of<PassDB>(context, listen: false).getJourney(1000);
    print(Provider.of<PassDB>(context, listen: false).journey);
  }

  @override
  void initState() {
    super.initState();
    _addCustomMarker1();
    _addCustomMarker2();
    _determinePosition();
    _fetchRoute();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _currentLocation == const LatLng(0, 0)
        ? loadingGPS()
        : Stack(children: <Widget>[
            GoogleMap(
              mapType: _currentMapType,
              onMapCreated: (GoogleMapController controller) {
                _MapController.complete(controller);
                controller.showMarkerInfoWindow(const MarkerId('current'));
              },
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 15,
              ),
              myLocationButtonEnabled: true,
              markers: {
                //Current Location marker
                Marker(
                  icon: markerIcon1,
                  markerId: const MarkerId('current'),
                  position: _currentLocation,
                  infoWindow: const InfoWindow(title: 'My location'),
                ),
                for (var marker in Provider.of<PassDB>(context).journeyMarker)
                  Marker(
                      icon: markerIcon2,
                      markerId: marker['markerId'],
                      position: marker['position'],
                      infoWindow: marker['infoWindow'])

                //Other markers
              },
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              right: 20,
              child: Container(
                width: 50,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _changeTerrain();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.traffic_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Divider(),
                      GestureDetector(
                        onTap: () {
                          _goToCurrent();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ]);
  }

  Widget loadingGPS() => SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCube(
              color: Theme.of(context).primaryColor,
              size: 50.0,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              _GpsError == '' ? "Waiting for GPS..." : _GpsError,
              style: GoogleFonts.nunito(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            IconButton.filled(
              color: Theme.of(context).primaryColor,
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _determinePosition();
              },
            )
          ],
        ),
      ));
}
