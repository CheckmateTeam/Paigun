import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paigun/page/chatroom/component/message.dart';
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
      // return response;x
      return "success";
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }


  Future<dynamic> sendMessage(String content,String roomId) async{
     try {
      final res = await supabase.from('message').
      insert({
        'roomId':roomId, // How to get roomId
        'content':content,
        'profileId': user,
      });
      return res;
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> chatCreate(User customer) async{
     try {
      final res = await supabase.from('message').
      insert({
        'ownerId': user,
        'userId':customer,
      })
      ;
      return res;
    } catch (e) {
      print(e);
    }
  }
  
  Future<dynamic> getMessage(String roomId) async{
     try {
      Message res = await supabase.from('message').
      select('messageId, roomId, date, created_at, content, profileId')
      .match({'roomId' : roomId});[
      ];
      return res;
    } catch (e) {
      print(e);
    }

    Future<dynamic> getChat() async {
      try {
      final res = await supabase.from('chat').
      select('roomId, userId, ownerId, created_at')
      .match({'ownerId' : user});[
      ];
      return res;
    } catch (e) {
      print(e);
    }
    }
  }
}
