import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paigun/model/journey_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../function/show_snackbar.dart';

class PassDB extends ChangeNotifier {
  Session? session = supabase.auth.currentSession;
  User? user = supabase.auth.currentUser;

  LatLng _currentPosition = const LatLng(0, 0);

  LatLng get currentPosition => _currentPosition;
  List get journey => _journey;
  List _journey = [];
  List<Marker> _journeyMarker = [];

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<dynamic> getOwner(String oid) async {
    try {
      final response = await supabase
          .from('users')
          .select('id, username, full_name, avatar_url')
          .eq('id', oid);
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> getJourney(int fetchDistance) async {
    try {
      final response = await supabase
          .from('journey')
          .select()
          .eq('status', 'available')
          .neq('owner', user!.id);
      _journey.clear();
      for (var i in response) {
        int distance = calculateDistance(
                LatLng(double.parse(i['origin_lat']), 0).latitude,
                LatLng(0, double.parse(i['origin_lng'])).longitude,
                LatLng(double.parse(i['destination_lat']), 0).latitude,
                LatLng(0, double.parse(i['destination_lng'])).longitude)
            .round();
        if (distance <= fetchDistance) {
          _journey.add({
            'journey_id': i['journey_id'],
            'owner': i['owner'],
            'origin_lat': i['origin_lat'],
            'destination_lat': i['destination_lat'],
            'origin_lng': i['origin_lng'],
            'destination_lng': i['destination_lng'],
            'origin_province': i['origin_province'],
            'destination_province': i['destination_province'],
            'date': i['date'],
            'available_seat': i['available_seat'],
            'price_seat': i['price_seat'],
            'car_brand': i['car_brand'],
            'car_model': i['car_model'],
            'status': i['status'],
            'note': i['note'],
          });
          _journeyMarker.add(Marker(
              markerId: MarkerId(i['journey_id']),
              position: LatLng(double.parse(i['origin_lat']),
                  double.parse(i['origin_lng']))));
        }
      }
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> getJourneyByProvince(
      String oriProvince, String destProvince) async {
    try {
      final response = await supabase.from('journey').select().match({
        'origin_province': oriProvince,
        'destination_province': destProvince,
        'status': 'available'
      }).neq('owner', user!.id);
      _journey.clear();
      _journey.addAll(response);
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<void> updatePosition(LatLng position) async {
    _currentPosition = position;
    notifyListeners();
  }
}
