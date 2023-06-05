import 'package:google_maps_flutter/google_maps_flutter.dart';

class Journey {
  String id;
  LatLng start;
  LatLng end;
  DateTime time;
  String seat;
  String price;
  String carBrand;
  String carModel;
  String note;

  Journey(
      {this.id = '',
      required this.start,
      required this.end,
      required this.time,
      required this.seat,
      required this.price,
      required this.carBrand,
      required this.carModel,
      required this.note});
}
