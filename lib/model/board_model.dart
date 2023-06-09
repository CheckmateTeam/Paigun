
class Board {
  String id;
  String owner;
  String origin;
  String destination;
  String note;
  String date;

  Board(
      {this.id = '',
      this.owner = '',
      required this.date,
      required this.origin,
      required this.destination,
      this.note = ''});
}
