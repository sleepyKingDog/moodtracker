import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'model/feeling_model.dart'; // Import your Feeling model
import 'model/journal_model.dart'; // Import your Journal model

class MoodProvider with ChangeNotifier {
  List<Feeling> _feelings = [];
  List<Journal> _journals = [];

  List<Feeling> get feelings => _feelings;
  List<Journal> get journals => _journals;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Method to load feelings from the database
  Future<void> loadFeelings() async {
    final data = await _dbHelper.getFeelings();
    _feelings = data.map((item) => Feeling.fromMap(item)).toList();
    notifyListeners();
  }

  // Method to add feeling to the database
  Future<void> addFeeling(Feeling feeling) async {
    await _dbHelper.insertFeeling(feeling);
    await loadFeelings();
  }

  // Similar methods for journals...
}
