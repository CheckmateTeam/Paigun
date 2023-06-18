import 'package:flutter/material.dart';
import 'package:paigun/provider/userinfo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../function/show_snackbar.dart';
import '../../chatroom/component/room.dart';
import '../../components/sizeappbar.dart';
import 'chatroom.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom(
    {Key? key}) : super(key: key);
  @override
  State<ChatRoom> createState() => _ChatRoom();
}

class _ChatRoom extends State<ChatRoom> {
  var _room;
  var _participants;

  

    void testfetch() {
    supabase.from('room_participants').stream(primaryKey: ['room_id']).listen(
        (List<Map<String, dynamic>> data) {
      print(data);
      print('success');
      });
    }


    dynamic getparticipants(String room_id)async{
      final data = await supabase.rpc('get_chatroom_participants', params: {'room_id' : room_id});
      return data;
    }
    
    void initState(){
      testfetch();
    }
    
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: SizeAppbar(context, "Chat",
            () => Navigator.pushReplacementNamed(context, '/home')),
        body: 
        
        StreamBuilder<List>(
            stream: Supabase.instance.client
                .from('room_participants')
                .stream(primaryKey: ['room_id', 'profile_id'])
                .order('created_at')
                .eq('profile_id', UserInfo().user!.id)
                .map((maps) => maps.map(Room.fromMap).toList()),
            initialData: [],
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('loading...'),
                );
              }

              
              final rooms = snapshot.data!;
              

              if (rooms.isEmpty) {
                return const Center(
                  child: Text("no room"),
                );
              }

              return Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                            child: Container(
                          child: ListView.builder(
                              padding: EdgeInsets.all(10),
                              itemCount: rooms.length,
                              itemBuilder: (context, index) {
                                final room = rooms[index];
                                //final roomtitle = _participants[index];
                                return roomBox(
                                  room: room, 
                                  //title:roomtitle
                                  );
                              }),
                        ))
                      ]));

              
            })
        );
  }





// ListView.builder(
              // itemCount: rooms.length,
              // itemBuilder: (context, index) {
              //   final room = rooms[index];
              //   return roomBox(room: room);
              // });


  Widget roomBox(
    {
      required Room room,
      //required String title
    }) {
    return InkWell(
      onTap: () => {Navigator.pushNamed(context as BuildContext, '/chat')},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        margin: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color.fromARGB(139, 221, 221, 221)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 193, 193, 193),
              blurRadius: 4,
              offset: Offset(0, 0), // Shadow position
            ),
          ],
        ),

        //list start here

        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.only(right: 10),
                child: Image.asset("assets/images/journeyboardmock.png")),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.room_id,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ]),
            )
          ],
        ),
      ),
    );
  }
}




//                 child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                   Container(
//                       padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(30),
//                           color: Color.fromARGB(255, 199, 199, 199)),
//                       child: Row(
//                         children: [
//                           TextButton(
//                             style: ButtonStyle(
//                               backgroundColor: MaterialStatePropertyAll(
//                                   Color.fromARGB((currentChat == 1) ? 255 : 0,
//                                       36, 70, 221)),
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 currentChat = 1;
//                               });
//                             },
//                             child: Text(
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     height: 0,
//                                     color: (currentChat == 1)
//                                         ? Colors.white
//                                         : Colors.black),
//                                 "Driver"),
//                           ),
//                           TextButton(
//                             style: ButtonStyle(
//                               backgroundColor: MaterialStatePropertyAll(
//                                   Color.fromARGB((currentChat == 1) ? 0 : 255,
//                                       36, 70, 221)),
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 currentChat = 2;
//                               });
//                             },
//                             child: Text(
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     height: 0,
//                                     color: (currentChat == 1)
//                                         ? Colors.black
//                                         : Colors.white),
//                                 "Passenger"),
//                           )
//                         ],
//                       )),
//                 ])),









//// SizedBox(height:20,),


                // Expanded(
                //   child: ListView.builder(
                //     itemCount: chatList.length,
                //     itemBuilder: (context,index){
                //       return chatBox((currentChat == 1)
                //                         ? chatList[index]['Name'] : chatListP[index]['Name'],
                //                       (currentChat == 1)
                //                         ? chatList[index]['Message'] : chatListP[index]['Message']);
                //     }))