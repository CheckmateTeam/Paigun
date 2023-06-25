import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:paigun/model/journey_model.dart';
import 'package:paigun/page/passenger/components/routedetail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../function/dioConfig.dart';
import '../function/show_snackbar.dart';
import '../main.dart';
import '../model/board_model.dart';

class PassDB extends ChangeNotifier {
  Session? session = supabase.auth.currentSession;
  User? user = supabase.auth.currentUser;

  LatLng _currentPosition = const LatLng(0, 0);
  LatLng _cameraPosition = const LatLng(0, 0);
  LatLng get currentPosition => _currentPosition;
  LatLng get cameraPosition => _cameraPosition;
  List get journey => _journey;
  List get board => _board;
  List get journeyMarker => _journeyMarker;
  List get journeyRequest => _journeyRequest;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;

  List _journey = [];
  List _journeyMarker = [];
  List _journeyRequest = [];
  List _board = [];
  bool _isSearching = false;
  bool _isLoading = false;

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<dynamic> getOwner(String oid) async {
    try {
      final fetch = await dio.get(
        '/journey',
        queryParameters: {'type': 'getuserprofile', 'userid': oid},
      );
      final response = fetch.data;
      // final response = await supabase
      //     .from('profile')
      //     .select('id, username, full_name, avatar_url')
      //     .eq('id', oid);
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<String> getJourneyStatus(String jid) async {
    try {
      final fetch = await dio.get(
        '/journey',
        queryParameters: {
          'type': 'getjourneystatus',
          'userid': user!.id,
          'journeyid': jid
        },
      );
      final response = fetch.data;
      // final response = await supabase
      //     .from('user_journey')
      //     .select('status')
      //     .eq('user_id', user!.id)
      //     .eq('journey_id', jid)
      //     .limit(1)
      //     .single();
      return response['status'];
    } catch (e) {
      print(e);
      return 'failed';
    }
  }

  Future<dynamic> getJourney(int fetchDistance) async {
    try {
      // final fetch = await dio.get(
      //   '/journey',
      //   queryParameters: {'type': 'getjourney', 'userid': user!.id},
      // );
      // final response = fetch.data;
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
                cameraPosition.latitude,
                cameraPosition.longitude)
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
                snippet: i['date'].toString().substring(0, 10),
                onTap: () async {
                  setLoading(true);
                  Map driver = await getOwner(i['owner']);
                  String status = await getJourneyStatus(i['journey_id']);
                  setLoading(false);
                  navigatorKey.currentState!
                      .push(MaterialPageRoute(builder: (context) {
                    return RouteDetail(
                        driver: driver, info: i, status: status, from: 'home');
                  }));
                }),
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
                    .format(DateTime.parse(i['date'])),
                onTap: () async {
                  setLoading(true);
                  Map driver = await getOwner(i['owner']);
                  String status = await getJourneyStatus(i['journey_id']);
                  setLoading(false);
                  navigatorKey.currentState!
                      .push(MaterialPageRoute(builder: (context) {
                    return RouteDetail(
                        driver: driver, info: i, status: status, from: 'home');
                  }));
                }),
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
      // final fetch = await dio.get(
      //   '/journey',
      //   queryParameters: {'type': 'getjourney', 'userid': user!.id},
      // );
      // final response = fetch.data;
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
              snippet: i['date'].toString().substring(0, 10),
              onTap: () async {
                setLoading(true);
                Map driver = await getOwner(i['owner']);
                String status = await getJourneyStatus(i['journey_id']);
                setLoading(false);
                navigatorKey.currentState!
                    .push(MaterialPageRoute(builder: (context) {
                  return RouteDetail(
                      driver: driver, info: i, status: status, from: 'home');
                }));
              }),
        });
      }
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> getJourneyDriver(String id) async {
    try {
      final fetch = await dio.get(
        '/journey',
        queryParameters: {'type': 'getuserprofile', 'userid': id},
      );
      final response = fetch.data;
      print(response);
      // final response = await supabase.from('profile').select().eq('id', id);
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
        //get seat price
        final response0 = await supabase
            .from('journey')
            .select('price_seat')
            .eq('journey_id', journeyId)
            .single();
        int priceSeat = response0['price_seat'];
        if (priceSeat == 0) {
          final response = await supabase
              .from('user_journey')
              .update({'status': "paid"})
              .eq('journey_id', journeyId)
              .eq('user_id', user!.id);
        } else {
          final response = await supabase
              .from('user_journey')
              .update({'status': "accepted"})
              .eq('journey_id', journeyId)
              .eq('user_id', user!.id);
        }

        //reduce available seat
        final response2 = await supabase
            .from('journey')
            .select('available_seat')
            .eq('journey_id', journeyId)
            .single();
        int availableSeat = response2['available_seat'];
        final response3 = await supabase.from('journey').update(
            {'available_seat': availableSeat - 1}).eq('journey_id', journeyId);
        return;
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

  Future<void> passengerReport(List<String> reportList, String jid) async {
    try {
      await supabase.from('journey_report').upsert({
        'journey': jid,
        'report': reportList,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> passengerFinishJourney(
      String jid, String comment, String driver, double rating) async {
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
      await supabase.from('journey_report').upsert([
        {
          'journey': jid,
          'comment': comment,
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

  void updateCameraPosition(LatLng position) {
    _cameraPosition = position;
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


  Future<String> gotoRoom(String user1, String user2) async {
    var room;
    var finalRoom;
    var room1;
    var room2;
    List uRoom1 = [];
    List uRoom2 = [];
    final isExist = await supabase
        .rpc('is_room_exist', params: {'user1': user1, 'user2': user2});

    if (!isExist) {
      room = await Supabase.instance.client.from('rooms').insert({}).select();
      await 
      supabase
      .from('room_participants')
      .insert({
        'profile_id':user1,
        'room_id': room[0]['id'],
      });

      await 
      supabase
      .from('room_participants')
      .insert({
        'profile_id':user2,
        'room_id': room[0]['id'],
      });

      finalRoom = room[0]['id'];
    } 
    else {
      room1 = await supabase
          .from('room_participants')
          .select('room_id')
          .eq('profile_id', user1);

      room2 = await supabase
          .from('room_participants')
          .select('room_id')
          .eq('profile_id', user2);

      for (var item in room1) {
        uRoom1.add(item['room_id']);
      }
      for (var item in room2) {
        uRoom2.add(item['room_id']);
      }

      for (var item in uRoom1) {
        if (uRoom2.contains(item)) {
          finalRoom = item;
        }
      }
    }
    return finalRoom;
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

  void setisSearching(bool bool) {
    _isSearching = bool;
    notifyListeners();
  }
}
