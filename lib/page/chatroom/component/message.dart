class Message {
  final String id;
  final String profile_id;
  final String content;
  final DateTime createdAt;
  final String roomId;
  

  Message({
    required this.id,
    required this.createdAt,
    required this.profile_id,
    required this.roomId,
    required this.content,
  });

  Message.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        createdAt = DateTime.parse(map['created_at']),
        profile_id = map['profile_id'],
        roomId = map['roomId'],
        content = map['content'];
}