class Journal {
  int? id; // Primary Key
  int feelingId; // Foreign Key
  String journal; // Journal text

  Journal({this.id, required this.feelingId, required this.journal});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'feelingId': feelingId,
      'journal': journal,
    };
  }

  factory Journal.fromMap(Map<String, dynamic> map) {
    return Journal(
      id: map['id'],
      feelingId: map['feelingId'],
      journal: map['journal'],
    );
  }
}
