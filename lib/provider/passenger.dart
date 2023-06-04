import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../function/show_snackbar.dart';

class PassDB extends ChangeNotifier {
  Session? session = supabase.auth.currentSession;
  User? user = supabase.auth.currentUser;

  LatLng _currentPosition = const LatLng(0, 0);

  LatLng get currentPosition => _currentPosition;

  Future<void> updatePosition(LatLng position) async {
    _currentPosition = position;
    notifyListeners();
  }
}
