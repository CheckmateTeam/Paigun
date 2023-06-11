import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../function/show_snackbar.dart';

class UserInfo extends ChangeNotifier {
  Session? session = supabase.auth.currentSession;
  User? user = supabase.auth.currentUser;
  Map _userinfo = {};
  get username async =>
      await supabase.from('profile').select('username').eq('id', user!.id);

  get phone => user!.phone;
  get userinfo => _userinfo;

  UserInfo() {
    getUserInfo();
  }

  Future<void> addNewUser(String phone, String name, String password) async {
    try {
      final UserResponse res = await supabase.auth.updateUser(
        UserAttributes(
          password: password,
        ),
      );
      final newUser = await supabase.from('profile').upsert({
        'id': supabase.auth.currentUser!.id,
        'username': phone.substring(1),
        'full_name': name,
        'avatar_url': '',
      });
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<dynamic> getUserInfo() async {
    try {
      final res = await supabase.from('profile').select().eq('id', user!.id);
      _userinfo = res[0];
      return res[0];
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<void> updateUsername(String name) async {
    try {
      final res = await supabase.from('profile').upsert({
        'id': supabase.auth.currentUser!.id,
        'username': supabase.auth.currentUser!.phone!,
        'full_name': name,
      });
      getUserInfo();
    } catch (e) {
      print(e);
    }
    getUserInfo();
    notifyListeners();
  }

  Future<void> updateProfileImage(String path) async {
    try {
      File image = File(path);
      String fileName = 'avatar_${user!.id}';
      String signedUrl = "";
      final avatar = await supabase
          .from('profile')
          .select('avatar_url')
          .eq('id', user!.id);
      if (avatar[0]['avatar_url'].toString().isEmpty) {
        final res = await supabase.storage.from('avatar').upload(
              fileName,
              image,
            );
      } else {
        final res = await supabase.storage.from('avatar').update(
              fileName,
              image,
            );
      }
      signedUrl = await supabase.storage
          .from('avatar')
          .createSignedUrl(fileName, 60 * 60 * 24 * 365);
      final res = await supabase.from('profile').upsert({
        'id': supabase.auth.currentUser!.id,
        'username': supabase.auth.currentUser!.phone!,
        'avatar_url': signedUrl,
      });
      _userinfo['avatar_url'] = signedUrl;
      notifyListeners();
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    try {
      final response = await supabase.auth.signOut();
      session = null;
      user = null;
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
