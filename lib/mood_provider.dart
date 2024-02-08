import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';
import 'model/feeling_model.dart'; // Import your Feeling model
import 'model/journal_model.dart'; // Import your Journal model

class MoodProvider with ChangeNotifier {
  List<Feeling> _feelings = [];
  List<Journal> _journals = [];

  List<Feeling> get feelings => _feelings;
    List<Journal> get journals {
    // journals を日付で降順にソート
    return [..._journals]..sort((a, b) => b.feeling_id.compareTo(a.feeling_id));
  }

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
    await _dbHelper
        .insertJournal(Journal(feeling_id: feelingid, journal: journal));
    await loadFeelings();
    await loadJournals();
  }

  LineChartData getMoodChartData() {
    if (_feelings.isEmpty) {
      // リストが空の場合は、空のグラフデータを返す
      return LineChartData(
        lineBarsData: [],
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      );
    }
    // 基準時間（最新の記録時間）を設定
    final DateTime endTime = _feelings.last.time; // リストが時間順にソートされていると仮定

    List<FlSpot> spots = _feelings.map((feeling) {
      // 基準時間（最新）から各記録時間までの経過時間を分で計算
      final double minutesFromEnd =
          endTime.difference(feeling.time).inMinutes.toDouble();
          

      double x = 10080 - minutesFromEnd; // 1週間を10080分として、最新の記録から逆算
      double y = feeling.feeling.toDouble();
      return FlSpot(x, y);
    }).toList();

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
        ),
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
            reservedSize: 50,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final double range = 10080; // Total minutes in a week
              // Assuming feelings are sorted by time, with the last being the most recent
              final double firstFeelingTime = _feelings.first.time
                  .difference(_feelings.first.time)
                  .inMinutes
                  .toDouble();
              final double lastFeelingTime = _feelings.last.time
                  .difference(_feelings.first.time)
                  .inMinutes
                  .toDouble();

              final double startLabel = firstFeelingTime;
              final double endLabel = lastFeelingTime;
              final double middleLabel = (startLabel + endLabel) / 2;

              // Only show labels for start, middle, and end points
              if (value == startLabel ||
                  value == middleLabel ||
                  value == endLabel) {
                DateTime date =
                    _feelings.first.time.add(Duration(minutes: value.toInt()));
                String formattedDate = DateFormat('MM/dd').format(date);
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(formattedDate),
                );
              } else {
                return Text('');
              }
            },

            reservedSize: 40,
          ),
        ),
        topTitles: const AxisTitles(
          // Disable top x-axis titles
          sideTitles: SideTitles(
            showTitles: false, // Hide titles on the top x-axis
          ),
        ),
        rightTitles: const AxisTitles(
          // Disable right y-axis titles
          sideTitles: SideTitles(
            showTitles: false, // Hide titles on the right y-axis
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingVerticalLine: (value) {
          if (value == 0) {
            // Only draw the horizontal line at y=0
            return const FlLine(
              color: Colors.grey,
              strokeWidth: 1,
            );
          }
          return const FlLine(
            color: Colors
                .transparent, // Hide other lines by making them transparent
          );
        },
      ),
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
