class Feeling {
  int? feeling_id; // Primary Key
  int feeling; // Mood value: 1 (good), 0 (neutral), -1 (bad)
  DateTime time; // Timestamp

  Feeling({this.feeling_id, required this.feeling, required this.time});

  Map<String, dynamic> toMap() {
    return {
      'feeling_id': feeling_id,
      'feeling': feeling,
      'time': time.toIso8601String(),
    };
  }

  factory Feeling.fromMap(Map<String, dynamic> map) {
    return Feeling(
      feeling_id: map['feeling_id'],
      feeling: map['feeling'],
      time: DateTime.parse(map['time']),
    );
  }
}
