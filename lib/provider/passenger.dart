import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:paigun/model/journey_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../function/show_snackbar.dart';
import '../model/board_model.dart';

class PassDB extends ChangeNotifier {
  Session? session = supabase.auth.currentSession;
  User? user = supabase.auth.currentUser;

  LatLng _currentPosition = const LatLng(0, 0);

  LatLng get currentPosition => _currentPosition;
  List get journey => _journey;
  List get board => _board;
  List get journeyMarker => _journeyMarker;
  List get journeyRequest => _journeyRequest;
  List _journey = [];
  List _journeyMarker = [];
  List _journeyRequest = [];
  List _board = [];

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

  Future<String> getJourneyStatus(String jid) async {
    try {
      final response = await supabase
          .from('user_journey')
          .select('status')
          .eq('user_id', user!.id)
          .eq('journey_id', jid)
          .limit(1)
          .single();
      return response['status'];
    } catch (e) {
      print(e);
      return 'failed';
    }
  }

  Future<dynamic> getJourney(int fetchDistance) async {
    try {
      final response = await supabase
          .from('journey')
          .select()
          .eq('status', 'available')
          .neq('owner', user!.id)
          .gt('available_seat', 0);
      _journey.clear();
      _journeyMarker.clear();
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
          _journeyMarker.add({
            'markerId': MarkerId(i['journey_id']),
            'position': LatLng(
                double.parse(i['origin_lat']), double.parse(i['origin_lng'])),
            'infoWindow': InfoWindow(
                title: i['destination_province'],
                snippet: i['date'].toString().substring(0, 10)),
          });
        }
      }
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> getJourneyByMap(int fetchDistance, LatLng currPos) async {
    try {
      final response = await supabase
          .from('journey')
          .select()
          .eq('status', 'available')
          .neq('owner', user!.id)
          .gt('available_seat', 0);
      _journey.clear();
      _journeyMarker.clear();
      for (var i in response) {
        int distance = calculateDistance(
                LatLng(double.parse(i['origin_lat']), 0).latitude,
                LatLng(0, double.parse(i['origin_lng'])).longitude,
                currPos.latitude,
                currPos.longitude)
            .round();
        if (distance <= fetchDistance - 0.5) {
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
          _journeyMarker.add({
            'markerId': MarkerId(i['journey_id']),
            'position': LatLng(
                double.parse(i['origin_lat']), double.parse(i['origin_lng'])),
            'infoWindow': InfoWindow(
                title: i['destination_province'],
                snippet: DateFormat('dd/MM/yyyy hh:mm a')
                    .format(DateTime.parse(i['date']))),
          });
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
      final response = await supabase
          .from('journey')
          .select()
          .match({
            'origin_province': oriProvince,
            'destination_province': destProvince,
            'status': 'available'
          })
          .neq('owner', user!.id)
          .gt('available_seat', 0);
      _journey.clear();
      _journeyMarker.clear();
      _journey.addAll(response);
      for (var i in response) {
        _journeyMarker.add({
          'markerId': MarkerId(i['journey_id']),
          'position': LatLng(
              double.parse(i['origin_lat']), double.parse(i['origin_lng'])),
          'infoWindow': InfoWindow(
              title: i['destination_province'],
              snippet: i['date'].toString().substring(0, 10)),
        });
      }
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> getJourneyDriver(String id) async {
    try {
      final response = await supabase.from('profile').select().eq('id', id);
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> getReqeustJourneyHistory() async {
    try {
      final response = await supabase
          .from('user_journey')
          .select('journey_id!inner(owner!inner(*),*),status')
          .eq('user_id', user!.id)
          .order('create_at', ascending: false);
      print(response);
      _journeyRequest.clear();
      _journeyRequest.addAll(response);
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> setUserRequest(String type, String journeyId) async {
    try {
      if (type == "join") {
        final response = await supabase.from('user_journey').upsert({
          'journey_id': journeyId,
          'user_id': user!.id,
          'status': "pending"
        });
        return response;
      } else if (type == "cancel") {
        final response = await supabase
            .from('user_journey')
            .delete()
            .eq('journey_id', journeyId)
            .eq('user_id', user!.id);
        return response;
      } else if (type == "pay") {
        final response = await supabase
            .from('user_journey')
            .update({'status': "paid"}).eq('journey_id', journeyId);
        return response;
      } else if (type == "accept") {
        final response = await supabase
            .from('user_journey')
            .update({'status': "accepted"})
            .eq('journey_id', journeyId)
            .eq('user_id', user!.id);

        //reduce available seat
        final response2 = await supabase
            .from('journey')
            .select('available_seat')
            .eq('journey_id', journeyId)
            .single();
        int availableSeat = response2['available_seat'];
        final response3 = await supabase.from('journey').update(
            {'available_seat': availableSeat - 1}).eq('journey_id', journeyId);
        return response;
      } else if (type == "decline") {
        final response = await supabase
            .from('user_journey')
            .delete()
            .eq('journey_id', journeyId);
        return response;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> passengerFinishJourney(String jid, String comment, String driver,
      double rating, List<String> report) async {
    try {
      await supabase
          .from('user_journey')
          .update({'status': 'done'})
          .eq('journey_id', jid)
          .eq('user_id', user!.id);

      //rating driver
      double oldRating = 0;
      double newrating = 0;
      final response = await supabase
          .from('profile')
          .select('rating')
          .eq('id', driver)
          .single();
      if (response['rating'] == null) {
        newrating = rating;
      } else {
        oldRating = double.parse(response['rating'].toString());
        newrating = (oldRating + rating) / 2;
      }

      await supabase
          .from('profile')
          .update({'rating': newrating}).eq('id', driver);

      //save report
      await supabase.from('journey_report').insert([
        {
          'journey': jid,
          'comment': comment,
          'report': report,
        }
      ]);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updatePosition(LatLng position) async {
    _currentPosition = position;
    notifyListeners();
  }

  Future<dynamic> createBoard(Board board) async {
    try {
      final response = await supabase.from('board').insert([
        {
          'owner': user!.id,
          'origin': board.origin,
          'destination': board.destination,
          'note': board.note,
          'date': board.date,
        }
      ]);
      return 'success';
    } catch (e) {
      return 'failed';
    }
  }

  Future<dynamic> getBoard() async {
    try {
      final response = await supabase.from('board').select(
          'board_id, owner, date, origin, destination, note, profile(id, username, full_name, avatar_url, rating)');
      _board = response;
      //print(response);
      return response;
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }
}
