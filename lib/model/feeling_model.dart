class Feeling {
  int? id; // Primary Key
  int feeling; // Mood value: 1 (good), 0 (neutral), -1 (bad)
  DateTime time; // Timestamp

  Feeling({this.id, required this.feeling, required this.time});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'feeling': feeling,
      'time': time.toIso8601String(),
    };
  }

  factory Feeling.fromMap(Map<String, dynamic> map) {
    return Feeling(
      id: map['id'],
      feeling: map['feeling'],
      time: DateTime.parse(map['time']),
    );
  }
}
