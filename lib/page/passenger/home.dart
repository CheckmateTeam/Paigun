import 'package:flutter/material.dart';

import '../../function/show_snackbar.dart';

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          Text('Passenger Home'),
          ElevatedButton(
              onPressed: () async {
                await supabase.auth.signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('Logout'))
        ],
      ),
    ));
  }
}
