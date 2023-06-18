import 'package:flutter/material.dart';
import 'package:paigun/provider/userinfo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../function/show_snackbar.dart';
import '../../chatroom/component/room.dart';
import '../../components/sizeappbar.dart';


class Chat extends StatefulWidget {
  const Chat(
    {Key? key}) : super(key: key);
  @override
  State<Chat> createState() => _Chat();
}

class _Chat extends State<Chat> {
  @override
  void initState() {
    super.initState();
    testfetch();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: SizeAppbar(context, "Chat",
            () => Navigator.pushReplacementNamed(context, '/home')),
        body: SizedBox(height: 10,));
  }

  void testfetch() {
    supabase.from('room_participants').stream(primaryKey: ['room_id']).listen(
        (List<Map<String, dynamic>> data) {
      print(data);
      print('success');
    });
  }
}