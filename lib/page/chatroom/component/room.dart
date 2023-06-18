class Room {
  final String roomId;
  final String userId;
  final DateTime createdAt;

  Room({
    required this.roomId,
    required this.userId,
    required this.createdAt,
  });

  Room.fromMap(Map<String, dynamic> map)
      : roomId = map['roomId'],
        userId = map['userId'] ?? 'Unknown',
        createdAt = DateTime.parse(map['created_at']);
}