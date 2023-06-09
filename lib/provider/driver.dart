import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../function/show_snackbar.dart';
import '../model/journey_model.dart';

class DriveDB extends ChangeNotifier {
  Session? session = supabase.auth.currentSession;
  User? user = supabase.auth.currentUser;

  List _journey = [];
  Map _request = {
    'request': 0,
    'journey': [],
  };

  get driverJourney => _journey;
  get request => _request['request'];
  get requestJourney => _request['journey'];
  Future<dynamic> CreateRoute(Journey journey) async {
    try {
      final response = await supabase.from('journey').insert([
        {
          'owner': user!.id,
          'origin_lat': journey.start.latitude,
          'destination_lat': journey.end.latitude,
          'origin_lng': journey.start.longitude,
          'destination_lng': journey.end.longitude,
          'origin_province': journey.startProvince,
          'destination_province': journey.endProvince,
          'date': journey.time.toIso8601String(),
          'available_seat': journey.seat,
          'price_seat': journey.price,
          'car_brand': journey.carBrand,
          'car_model': journey.carModel,
          'status': "available",
          'note': journey.note,
        }
      ]);
      return 'success';
    } catch (e) {
      return 'failed';
    }
  }

  Future<dynamic> getDriverJourney() async {
    try {
      //journey list
      final response = await supabase
          .from('journey')
          .select()
          .eq('owner', user!.id)
          .order('date', ascending: false);
      //request list
      final response2 = await supabase
          .from('user_journey')
          .select('journey_id!inner(*),user_id!inner(*),status,create_at')
          .eq('status', 'paid')
          .neq('user_id.id', user!.id);
      _journey.clear();
      _journey.addAll(response);
      _request['request'] = response2.length;
      _request['journey'].clear();
      _request['journey'].addAll(response2);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
