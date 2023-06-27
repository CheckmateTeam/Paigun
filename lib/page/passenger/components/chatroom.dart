import 'package:flutter/material.dart';
import 'package:paigun/provider/userinfo.dart';
import '../../../function/show_snackbar.dart';
import '../../chatroom/component/message.dart';
import '../../chatroom/component/room.dart';
import '../../components/sizeappbar.dart';
import 'chatmessage.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key}) : super(key: key);
  @override
  State<ChatRoom> createState() => _ChatRoom();
}

class _ChatRoom extends State<ChatRoom> {
  int prevChange = 0;
  int unRead = 0;
  Map<int, List> _participantsList = {};
  Map<String, List> _roominfo = {};

  Future<String> getparticipants(String roomId, int index) async {
    final data = await supabase
        .rpc('get_chatroom_participants', params: {'roomid': roomId});
    String currentUser = UserInfo().user!.id;
    String opponent = "";
    String avatar = "";
    String id = "";
    for (var item in data) {
      if (item['id'] != currentUser) {
        opponent = item['full_name'];
        avatar = item['avatar_url'];
        id = item['id'];
        _participantsList[index] = [opponent, avatar, id];
      }
    }
    setState(() {});
    return opponent;
  }

// 0 = unRead
// 1 = lastSend

  Future<int> getRoomInfo() async {
    
    final room = await supabase
        .from('room_participants')
        .select()
        .eq('profile_id', UserInfo().user!.id);

    for (var item in room) {
      String roomid = item['room_id'];
      final unRead = await supabase
          .from('messages')
          .select()
          .eq('roomid', roomid)
          .eq('is_read', false)
          .neq('profile_id', UserInfo().user!.id);

      final lastSend = await supabase
          .from('messages')
          .select()
          .eq('roomid', roomid)
          .order('created_at');

      setState(() {
        _roominfo[roomid] = [unRead.length, lastSend[0]['content']];
      });


    }

    return 0;
  }

  @override
  void initState() {
    getRoomInfo();
    supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen((messages) {
          getRoomInfo();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SizeAppbar(context, "Chat",
            () => Navigator.pushReplacementNamed(context, '/home')),
        body: StreamBuilder<List>(
            stream: supabase
                .from('room_participants')
                .stream(primaryKey: ['room_id', 'profile_id'])
                .order('created_at')
                .eq('profile_id', UserInfo().user!.id)
                .map((maps) => maps.map(Room.fromMap).toList()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('loading...'),
                );
              }

              final rooms = snapshot.data!;
              if (prevChange != rooms.length) {
                for (var item in rooms) {
                  getparticipants(item.room_id, rooms.indexOf(item));
                }
                setState(() {
                  prevChange = rooms.length;
                });
              }
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
                                return roomBox(
                                  room: room,
                                  title: _participantsList[index] == null
                                      ? "loading..."
                                      : _participantsList[index]!.toList()[0],
                                  avatar: _participantsList[index] == null
                                      ? "loading"
                                      : _participantsList[index]!.toList()[1],
                                  id: _participantsList[index] == null
                                      ? "loading"
                                      : _participantsList[index]!.toList()[2],
                                );
                              }),
                        ))
                      ]));
            }));
  }

  Widget roomBox(
      {required Room room,
      required String title,
      required String avatar,
      required String id}) {
    return title == "loading..." || avatar == "loading"
        ? Container()
        : InkWell(
            onTap: () => {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ChatRoomMessage(
                  room_id: room.room_id,
                  title: title,
                );
              }))
            },
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
                      child: avatar == "loading"
                          ? Text("loading")
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              
                              child: Image.network(avatar, loadingBuilder:
                                  (BuildContext context, Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }, errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Image.asset(
                                      'assets/images/avatarmock.png'),
                                );
                              }))),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _roominfo[room.room_id]?[1] ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: (_roominfo[room.room_id]?[0] ?? 0) == 0 ? FontWeight.w400 : FontWeight.w600,
                              color: (_roominfo[room.room_id]?[0] ?? 0) == 0 ? Color.fromARGB(255, 77, 77, 77) : Colors.black,
                              fontSize: 15,
                            ),
                            
                          ),
                        ]),
                  ),
                  (_roominfo[room.room_id]?[0] ?? 0)  == 0
                      ? Container()
                      : Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 57, 54, 244),
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              _roominfo[room.room_id]?[0].toString() ?? '',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                          ))
                ],
              ),
            ),
          );
  }
}
