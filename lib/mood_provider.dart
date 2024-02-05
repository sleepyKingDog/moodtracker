import 'package:fl_chart/fl_chart.dart';
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
  Future<int> addFeeling(mood, time) async {
    int id = await _dbHelper.insertFeeling(Feeling(feeling: mood, time: time));
    await loadFeelings();
    return id;
  }

  Future<void> loadJournals() async {
    final data = await _dbHelper.getJournals();
    _journals = data.map((item) => Journal.fromMap(item)).toList();
    notifyListeners();
  }

  // Method to add feeling to the database
  Future<void> addJournal(feelingid, journal) async {
    await _dbHelper.insertJournal(Journal(feeling_id: feelingid, journal: journal));
    await loadFeelings();
  }

  LineChartData getMoodChartData() {
    List<FlSpot> spots = _feelings.asMap().entries.map((entry) {
      int index = entry.key;
      Feeling feeling = entry.value;
      // For demonstration, we're simply using the index as the x-value
      double x = index.toDouble();
      double y = feeling.feeling.toDouble();
      return FlSpot(x, y);
    }).toList();

    return LineChartData(
      lineBarsData: [
        LineChartBarData(spots: spots),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value == 1) return Text('Good');
              if (value == 0) return Text('Normal');
              if (value == -1) return Text('Bad');
              return Text('');
            },
            reservedSize: 40,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              // Check if the index is within the bounds of the list
              if (value.toInt() < _feelings.length && value.toInt() >= 0) {
                final feelingEntry = _feelings[value.toInt()];
                // Additionally, ensure that the 'time' property is not null
                if (feelingEntry != null && feelingEntry.time != null) {
                  return Text(feelingEntry.time.toString().split(' ')[0]);
                }
              }
              // Return a default or placeholder widget if conditions are not met
              return Text('');
            },
            reservedSize: 30,
          ),
        ),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
    );
  }

  DateTime? getFeelingTimeById(int feelingId) {
    // Using try-catch to handle the case where no match is found
    try {
      final feeling = _feelings.firstWhere((f) => f.feeling_id == feelingId);
      return feeling.time; // Assuming 'time' is a non-nullable DateTime
    } catch (e) {
      // Return null if no matching feeling is found
      return null;
    }
  }
}
