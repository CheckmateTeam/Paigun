import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../function/show_snackbar.dart';
import '../model/journey_model.dart';

class DriveDB extends ChangeNotifier {
  Session? session = supabase.auth.currentSession;
  User? user = supabase.auth.currentUser;

  Future<dynamic> CreateRoute(Journey journey) async {
    try {
      print(journey.time);
      // final response = await supabase.from('journeys').insert([
      //   {
      //     'start': journey.start,
      //     'end': journey.end,
      //     'time': journey.time,
      //     'seat': journey.seat,
      //     'price': journey.price,
      //     'car_brand': journey.carBrand,
      //     'car_model': journey.carModel,
      //     'note': journey.note,
      //   }
      // ]);
      // return response;
      return "success";
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }
}
