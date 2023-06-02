import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../function/show_snackbar.dart';

class UserInfo extends ChangeNotifier {
  Session? session = supabase.auth.currentSession;
  User? user = supabase.auth.currentUser;

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
}
