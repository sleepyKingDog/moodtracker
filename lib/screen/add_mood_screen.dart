import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mirhyth/mood_provider.dart';
import 'package:mirhyth/model/feeling_model.dart';
import 'package:mirhyth/model/journal_model.dart';


class AddMoodScreen extends StatefulWidget {
  @override
  _AddMoodScreenState createState() => _AddMoodScreenState();
}

class _AddMoodScreenState extends State<AddMoodScreen> {
  int? _selectedMood; // 1: good, 0: normal, -1: bad
  final TextEditingController _journalController = TextEditingController();

  void _saveMoodAndJournal() async {
    if (_selectedMood != null) {
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      // Assuming addFeeling now returns the id of the newly inserted feeling record
      final int feelingId =
          await moodProvider.addFeeling(_selectedMood!, DateTime.now());

      // If journal text is not empty, add it to the database
      if (_journalController.text.isNotEmpty) {
        // Now that we have the feelingId, we can use it directly
        await moodProvider.addJournal(feelingId, _journalController.text);
        
      }

      // After saving, go back to the home screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Mood'),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Good'),
            leading: Radio(
              value: 1,
              groupValue: _selectedMood,
              onChanged: (int? value) {
                setState(() {
                  _selectedMood = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Normal'),
            leading: Radio(
              value: 0,
              groupValue: _selectedMood,
              onChanged: (int? value) {
                setState(() {
                  _selectedMood = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Bad'),
            leading: Radio(
              value: -1,
              groupValue: _selectedMood,
              onChanged: (int? value) {
                setState(() {
                  _selectedMood = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _journalController,
              decoration: InputDecoration(
                labelText: 'Journal (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ),
          ElevatedButton(
            onPressed: _saveMoodAndJournal,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
