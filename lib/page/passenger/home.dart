import 'dart:async';
import 'package:faker/faker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:paigun/page/passenger/components/drawer.dart';
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
  String destination = '';
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
            grabbingHeight: MediaQuery.of(context).size.height * 0.08,
            grabbing: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
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
                      Text(
                        'Nearby routes',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                )),
            sheetBelow: SnappingSheetContent(
              childScrollController: _myScrollController,
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
                      itemCount: 30,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
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
                                onTap: () {},
                                leading: const Icon(Icons.call_split_rounded),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      faker.address.country(),
                                      style: GoogleFonts.nunito(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Icon(Icons.arrow_right_alt_rounded,
                                        color: Colors.black),
                                    Text(
                                      faker.address.country(),
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
                                    DateFormat('dd/MM/yyyy hh:mm a')
                                        .format(faker.date.dateTime()),
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
                            // ignore: use_build_context_synchronously

                            _searchController.text = destination;
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    _addCustomMarker1();
    _addCustomMarker2();
    _determinePosition().then((value) {
      setState(() {
        _currentLocation = LatLng(value.latitude, value.longitude);
      });
    }).catchError((e) {
      print(e);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _currentLocation == const LatLng(0, 0)
        ? loadingGPS()
        : GoogleMap(
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              controller.showMarkerInfoWindow(const MarkerId('current'));
              _MapController.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
            myLocationButtonEnabled: true,
            // circles: {
            //   Circle(
            //       circleId: const CircleId('current'),
            //       center: _currentLocation,
            //       radius: 200,
            //       fillColor: Colors.blue.withOpacity(0.1),
            //       strokeColor: Colors.blue,
            //       strokeWidth: 1)
            // },
            markers: {
              //Current Location marker
              Marker(
                icon: markerIcon1,
                markerId: const MarkerId('current'),
                position: _currentLocation,
                infoWindow: const InfoWindow(title: 'My location'),
              ),

              //Other markers
            },
          );
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
              'Waiting for GPS...',
              style: GoogleFonts.nunito(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ));
}
