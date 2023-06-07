import 'package:google_maps_flutter/google_maps_flutter.dart';

class Journey {
  String id;
  String owner;
  LatLng start;
  LatLng end;
  String startProvince;
  String endProvince;
  DateTime time;
  String seat;
  String price;
  String carBrand;
  String carModel;
  String note;

  Journey(
      {this.id = '',
      this.owner = '',
      required this.start,
      required this.end,
      required this.startProvince,
      required this.endProvince,
      required this.time,
      required this.seat,
      required this.price,
      required this.carBrand,
      required this.carModel,
      required this.note});
}
