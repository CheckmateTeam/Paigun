class Message {
  final String id;
  final String profile_id;
  final String content;
  final DateTime createdAt;
  final String roomid;
  

  Message({
    required this.id,
    required this.createdAt,
    required this.profile_id,
    required this.roomid,
    required this.content,
  });

  Message.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        createdAt = DateTime.parse(map['created_at']),
        profile_id = map['profile_id'],
        roomid = map['roomid'],
        content = map['content'];
}