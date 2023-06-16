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
          .eq('status', 'pending')
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

  Future<String> getDriverJourneyStatus(String jid) async {
    try {
      final response = await supabase
          .from('journey')
          .select('status')
          .eq('journey_id', jid)
          .limit(1)
          .single();
      return response['status'];
    } catch (e) {
      print(e);
      return 'failed';
    }
  }

  Future<List> getJourneyPassenger(String jid) async {
    try {
      final response = await supabase
          .from('user_journey')
          .select('user_id!inner(*),status')
          .eq('journey_id', jid)
          .neq('status', 'pending')
          .neq('status', 'accepted');
      if (response.length == 0) {
        return [];
      }
      return response;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<String> changeJourneyStatus(String jid, String status) async {
    try {
      if (status == 'going') {
        final response = await supabase
            .from('journey')
            .update({'status': status}).eq('journey_id', jid);
        final response2 = await supabase
            .from('user_journey')
            .update({
              'status': status,
            })
            .eq('journey_id', jid)
            .eq('status', 'paid');
        final response3 = await supabase
            .from('user_journey')
            .delete()
            .eq('journey_id', jid)
            .eq('status', 'accepted');
        return response;
      } else {
        final response = await supabase
            .from('journey')
            .update({'status': status}).eq('journey_id', jid);
        final response2 = await supabase.from('user_journey').update({
          'status': status,
        }).eq('journey_id', jid);
        return response;
      }
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<dynamic> deleteRoute(String jid) async {
    try {
      final response =
          await supabase.from('journey').delete().eq('journey_id', jid);
      return 'success';
    } catch (e) {
      return 'failed';
    }
  }

  Future<dynamic> driverAcceptedRequest(String journeyId, String userId) async {
    final response = await supabase
        .from('user_journey')
        .update({'status': "accepted"})
        .eq('journey_id', journeyId)
        .eq('user_id', userId);

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
  }

  Future<dynamic> completeJourney(String jid) async {
    try {
      final response = await supabase
          .from('journey')
          .update({'status': 'done'}).eq('journey_id', jid);

      return 'success';
    } catch (e) {
      return 'failed';
    }
  }

  Future<dynamic> getJourneyInfo(String jid) async {
    try {
      final response = await supabase
          .from('journey')
          .select()
          .eq('owner', user!.id)
          .eq('journey_id', jid)
          .single();
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> isPassengerAllCompleted(String jid) async {
    try {
      final response = await supabase
          .from('user_journey')
          .select()
          .eq('journey_id', jid)
          .eq('status', 'finished');

      if (response.length == 0) {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
