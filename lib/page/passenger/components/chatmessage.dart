import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paigun/function/show_snackbar.dart';
import 'package:paigun/provider/userinfo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../chatroom/component/message.dart';
import '../../chatroom/component/profile.dart';
import '../../chatroom/component/room.dart';
import '../../components/sizeappbar.dart';

class ChatRoomMessage extends StatefulWidget {
  const ChatRoomMessage({
    Key? key,
    required this.room,
    required this.title,
  }) : super(key: key);

  final Room room;
  final String title;
  @override
  State<ChatRoomMessage> createState() => _ChatRoomMessage();
}

class _ChatRoomMessage extends State<ChatRoomMessage> {
  List<Message>? _messages;
  final Map<String, Profile> _profileCache = {};
  StreamSubscription<List<Message>>? _messagesListener;

  void fetchMessage() {
    _messagesListener = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .eq('roomId', '9abf76ca-240d-4e5a-a5c6-757b0a18979b')
        .map((maps) => maps.map(Message.fromMap).toList())
        .listen((messages) {
          print(messages);
        });
  }

  @override
  void initState() {
    _messagesListener = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .eq('roomId', widget.room.room_id)
        .map((maps) => maps.map(Message.fromMap).toList())
        .listen((messages) {
          print(messages);
          setState(() {
            _messages = messages;
          });
        });

    print(widget.room.room_id);
    print(widget.room.profile_id);
    print(widget.room.createdAt);
    print(widget.title);
    print(_messages);
    print('fetch done bro');
    super.initState();
  }

  Widget _messageList() {
    if (_messages == null) {
      return const Center(
        child: Text('Loading...'),
      );
    }
    if (_messages!.isEmpty) {
      return const Center(
        child: Text('No one has started talking yet...'),
      );
    }
    final userId = UserInfo().user!.id;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      reverse: true, 
      itemCount: _messages!.length,
      itemBuilder: ((context, index) {
        final message = _messages![index];
        var lastsend = DateTime.now();
        
        if(index < _messages!.length-1){
          lastsend = _messages![index+1].createdAt.add(Duration(minutes: 3));
        }
        return Align(
          alignment: userId == message.profile_id
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: message.createdAt.isBefore(lastsend) ? EdgeInsets.symmetric(vertical:  5) : EdgeInsets.only(top: 10),
            child: ChatBubble(
                userId: userId, message: message, opponent: widget.title, lastsend: lastsend,
                //profileCache: _profileCache,
                ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _messagesListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 0),
                )
              ],
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppBar(
                  leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home')),
                  title: Text(widget.title,
                      style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor))),
                  
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messageList(),
            ),
            ChatForm(
              roomId: widget.room.room_id,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble(
      {Key? key,
      required this.userId,
      required this.message,
      required this.opponent,
      required this.lastsend
      //required this.profileCache,
      })
      : super(key: key);

  final String? userId;
  final Message message;
  final String opponent;
  final DateTime lastsend;
  //final Map<String, Profile> profileCache;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: userId == message.profile_id
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        
        
        SizedBox(height: message.createdAt.isBefore(lastsend) ? 0:1),
        Row(
        mainAxisAlignment: userId == message.profile_id
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            userId == message.profile_id 
            ? '${message.createdAt.hour}:${message.createdAt.minute}' 
            : '',
            style: const TextStyle(fontSize: 12,height: 2),
          ),
          SizedBox(width:5),
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10),
          color: userId == message.profile_id
              ? Color.fromARGB(255, 91, 110, 255)
              : Colors.grey[300],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7,horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                      color: userId == message.profile_id
                          ? Color.fromARGB(255, 255, 255, 255)
                          : Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width:5),
        Text(
            !(userId == message.profile_id) 
            ? '${message.createdAt.hour}:${message.createdAt.minute}' 
            : '',
            style: const TextStyle(fontSize: 12,height: 2),
          ),
          
          
      ],)
      ],
    );
  }
}

class ChatForm extends StatefulWidget {
  const ChatForm({
    Key? key,
    required this.roomId,
  }) : super(key: key);

  final String roomId;

  @override
  State<ChatForm> createState() => _ChatFormState();
}

class _ChatFormState extends State<ChatForm> {
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            
            child: Container(
            //decoration: 
            child: 
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type something',
                fillColor: Colors.white,
                filled: true,
                border: InputBorder.none,
              ),
            ),
            )
          ),
          TextButton(
            onPressed: () async {
              final text = _textController.text;
              if (text.isEmpty) {
                return;
              }
              _textController.clear();
              final res =
                  await Supabase.instance.client.from('messages').insert({
                'roomId': widget.roomId,
                'profile_id': UserInfo().user!.id,
                'content': text,
              });

              final error = res.error;
              if (error != null && mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error.message)));
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}