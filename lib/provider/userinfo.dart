import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../function/show_snackbar.dart';

class UserInfo extends ChangeNotifier {
  Session? session = supabase.auth.currentSession;
  User? user = supabase.auth.currentUser;

  get username async =>
      await supabase.from('profiles').select('username').eq('id', user!.id);

  get phone => user!.phone;

  Future<void> addNewUser(String phone, String name, String password) async {
    try {
      final UserResponse res = await supabase.auth.updateUser(
        UserAttributes(
          password: password,
        ),
      );
      final newUser = await supabase.from('profile').upsert({
        'id': user!.id,
        'username': phone.substring(1),
        'full_name': name,
        'avatar_url': '',
      });
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    try {
      final response = await supabase.auth.signOut();
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
