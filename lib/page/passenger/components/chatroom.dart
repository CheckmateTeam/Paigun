import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/sizeappbar.dart';
import '../../chatroom/component/message.dart';
import '../../chatroom/component/room.dart';


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
  List<Message>? _messages = [];

  void getBoard() async {
    _journey = await context.read<PassDB>().getBoard();
    _showJourney = _journey;
    isLoading = false;
    setState(() {});
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
            const SizedBox(
              height: 15,
            ),
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromARGB(255, 199, 199, 199)),
                      child: Row(
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color.fromARGB((currentChat == 1) ? 255 : 0,
                                      36, 70, 221)),
                            ),
                            onPressed: () {
                              setState(() {
                                currentChat = 1;
                              });
                            },
                            child: Text(
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                    color: (currentChat == 1)
                                        ? Colors.white
                                        : Colors.black),
                                "Driver"),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color.fromARGB((currentChat == 1) ? 0 : 255,
                                      36, 70, 221)),
                            ),
                            onPressed: () {
                              setState(() {
                                currentChat = 2;
                              });
                            },
                            child: Text(
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                    color: (currentChat == 1)
                                        ? Colors.black
                                        : Colors.white),
                                "Passenger"),
                          )
                        ],
                      )),
                ])),


                SizedBox(height:20,),


                Expanded(
                  child: ListView.builder(
                    itemCount: chatList.length,
                    itemBuilder: (context,index){
                      return chatBox((currentChat == 1)
                                        ? chatList[index]['Name'] : chatListP[index]['Name'],
                                      (currentChat == 1)
                                        ? chatList[index]['Message'] : chatListP[index]['Message']);
                    }))
          ],
        ),
      ),,
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