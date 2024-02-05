class Journal {
  int? journal_id; // Primary Key
  int feeling_id; // Foreign Key
  String journal; // Journal text

  Journal({this.journal_id, required this.feeling_id, required this.journal});

  Map<String, dynamic> toMap() {
    return {
      'journal_id': journal_id,
      'feeling_id': feeling_id,
      'journal': journal,
    };
  }

  factory Journal.fromMap(Map<String, dynamic> map) {
    return Journal(
      journal_id: map['journal_id'],
      feeling_id: map['feeling_id'],
      journal: map['journal'],
    );
  }
}
