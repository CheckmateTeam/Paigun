import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../provider/driver.dart';
import '../../components/sizeappbar.dart';
import '../../chatroom/component/message.dart';
import '../../chatroom/component/room.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'db.rnkpkbfkrscmxfhjxlcs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJua3BrYmZrcnNjbXhmaGp4bGNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODU2MDcxMDgsImV4cCI6MjAwMTE4MzEwOH0.KiHk8j-KZgFeDgn1eMUCs1-xPQimPcTpNBkJ9p5Trzg',
  );

}


class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key, required this.room});

  final Room room;


  @override
  State<ChatRoom> createState() => _ChatRoom();
}

class _ChatRoom extends State<ChatRoom> {
  List _messages = [];

  void getMessage(Room room) async {
    _messages = await context.read<DriveDB>().getMessage(room.roomId);
    setState(() {});
  }

  void sendMessage(Message message) async{
    
    
    _messages = await context.read<DriveDB>().getMessage("user");
    
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SizeAppbar(context, "Username",
      () => Navigator.pushReplacementNamed(context, '/home')),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [

          ],
        ),
      ),
    );
    }




















  // Widget _messageList() {
  //     if (_messages == null) {
  //       return const Center(
  //         child: Text('Loading...'),
  //       );
  //     }
  //     if (_messages!.isEmpty) {
  //       return const Center(
  //         child: Text('No one has started talking yet...'),
  //       );
  //     }
  //     // final userId = Supabase.instance.client.auth.user()?.id;

  //     return ListView.builder(
  //       padding: const EdgeInsets.symmetric(
  //         horizontal: 12,
  //         vertical: 8,
  //       ),
  //       reverse: true,
  //       itemCount: _messages!.length,
  //       itemBuilder: ((context, index) {
  //         final message = _messages![index];
  //         return Align(
  //           alignment: Alignment.centerRight,
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8),
  //             child: ChatBubble(
  //               userId: userId,
  //               message: message,
  //               profileCache: _profileCache,
  //             ),
  //           ),
  //         );
  //       }),
  //     );
  //   }

  

    

  }



  class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    required this.userId,
    required this.message,
  }) : super(key: key);

  final String? userId;
  final Message message;


  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(4),
      color: userId == message.profileId ? Colors.grey[300] : Colors.blue[200],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'username',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            Text(
              message.content,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}