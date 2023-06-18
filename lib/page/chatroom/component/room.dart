class Room {
  final String room_id;
  final String profile_id;
  final DateTime created_at;

  Room({
    required this.room_id,
    required this.profile_id,
    required this.created_at,
  });

  Room.fromMap(Map<String, dynamic> map)
      : room_id = map['room_id'],
        profile_id = map['profile_id'] ?? 'Unknown',
        created_at = DateTime.parse(map['created_at']);
}