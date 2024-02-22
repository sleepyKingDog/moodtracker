import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mirhyth/model/journal_model.dart';
import 'package:provider/provider.dart';
import 'package:mirhyth/mood_provider.dart';
import 'package:mirhyth/journal_provider.dart';
import './add_mood_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // This is a good place to load data from the database if needed.
    // For example, you might want to call a method in your provider to load moods and journals.
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    moodProvider
        .loadFeelings(); // Make sure to implement this method in your provider
    moodProvider
        .loadJournals(); // Make sure to implement this method in your provider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Mood Tracker Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download Data'),
              onTap: () async {
                // Use MoodProvider to export data
                await Provider.of<MoodProvider>(context, listen: false)
                    .exportData();
                // ignore: use_build_context_synchronously
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Delete All Data'),
              onTap: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm'),
                      content: const Text('This will delete all data. Are you sure?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () async {
                            // Use MoodProvider to delete all data
                            await Provider.of<MoodProvider>(context,
                                    listen: false)
                                .deleteAllData();
                            Navigator.of(context).pop(); // Dismiss dialog
                            Navigator.pop(context); // Close the drawer
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                // This function should be implemented in your MoodProvider
                // to generate mood chart data based on the feelings stored in the database.
                Provider.of<MoodProvider>(context).getMoodChartData(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Consumer<MoodProvider>(
              builder: (context, moodProvider, child) {
                return ListView.builder(
                  itemCount: moodProvider.journals.length,
                  itemBuilder: (context, index) {
                    final journal = moodProvider.journals[index];
                    final DateTime? feelingTime =
                        moodProvider.getFeelingTimeById(journal.feeling_id);
                    // If feelingTime is null, provide a default or placeholder value
                    String formattedTime = feelingTime != null
                        ? DateFormat('yyyy-MM-dd – kk:mm').format(feelingTime)
                        : 'Unknown time';
                    return ListTile(
                      title: Text(journal.journal),
                      subtitle: Text(
                          formattedTime), // Now correctly displaying the associated feeling's time
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMoodScreen()),
          );
          // If the add mood screen returns any data, you might want to refresh your data.
          if (result != null) {
            final moodProvider =
                Provider.of<MoodProvider>(context, listen: false);
            moodProvider.loadFeelings(); // Refresh feelings
            moodProvider.loadJournals(); // Refresh journals
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
