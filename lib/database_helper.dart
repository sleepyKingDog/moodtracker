import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as p;
import 'model/feeling_model.dart'; // Import your Feeling model
import 'model/journal_model.dart'; // Import your Journal model
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();
  final int _databaseVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mood_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _databaseVersion, // Make sure this matches the updated version
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Drop the existing tables
    await db.execute('DROP TABLE IF EXISTS journals;');
    await db.execute('DROP TABLE IF EXISTS feelings;');

    // Recreate the updated tables
    await _createDB(db, newVersion);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE feelings (
        feeling_id INTEGER PRIMARY KEY AUTOINCREMENT,
        feeling INTEGER NOT NULL,
        time TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE journals (
        journal_id INTEGER PRIMARY KEY AUTOINCREMENT,
        feeling_id INTEGER NOT NULL,
        journal TEXT NOT NULL,
        FOREIGN KEY (feeling_id) REFERENCES feelings (feeling_id)
      )
    ''');
  }

  // Method to insert a new Feeling record
  Future<int> insertFeeling(Feeling feeling) async {
    print("feeling");
    final db = await database;
    final id = await db.insert('feelings', feeling.toMap());
    return id;
  }

  // Method to retrieve all Feeling records
  Future<List<Map<String, dynamic>>> getFeelings() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('feelings');
    return result;
  }

  // Method to insert a new Journal record
  Future<int> insertJournal(Journal journal) async {
    final db = await database;
    final id = await db.insert('journals', journal.toMap());
    return id;
  }

  // Method to retrieve all Journal records
  Future<List<Map<String, dynamic>>> getJournals() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('journals');
    return result;
  }

  // Method to delete a Journal record
  Future<int> deleteJournal(int id) async {
    final db = await database;
    final result =
        await db.delete('journals', where: 'id = ?', whereArgs: [id]);
    return result;
  }

  // Method to retrieve joined Journal and Feeling records
  Future<List<Map<String, dynamic>>> getJournalAndFeeling() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 
      feelings.feeling_id, 
      feelings.feeling, 
      feelings.time,
      journals.journal_id, 
      journals.journal
    FROM 
      feelings
    LEFT JOIN 
      journals ON feelings.feeling_id = journals.feeling_id;
  ''');
    return result;
  }

  Future<void> exportDataToExcel() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    var excel = Excel.createExcel();
    var sheet = excel['Data'];

    // Fetch joined data
    List<Map<String, dynamic>> joinedData = await getJournalAndFeeling();

    // Append headers
    sheet.appendRow([
      TextCellValue("Feeling ID"),
      TextCellValue("Feeling"),
      TextCellValue("Time"),
      TextCellValue("Journal"),
    ]);

    // Populate the sheet with joined data
    for (var row in joinedData) {
      // Directly using non-null values for `feeling_id` and `feeling` as they're expected to be non-null.
      // Using empty string for `null` values in `time` and `journal`.
      var rowData = [
        TextCellValue(row['feeling_id'].toString()),
        TextCellValue(row['feeling'].toString()),
        TextCellValue(row['time'] ?? ''),
        TextCellValue(row['journal'] ?? ''),
      ];

      sheet.appendRow(rowData);
    }

    List<int>? excelBytes = excel.save();
    if (excelBytes != null) {
      Uint8List fileBytes = Uint8List.fromList(excelBytes);
      await saveFileToDownloads(fileBytes, 'mood_tracker_data.xlsx');
    } else {
      print("Failed to generate Excel file");
    }
  }

  Future<void> saveFileToDownloads(Uint8List fileBytes, String fileName) async {
    // The MIME type for Excel files
    const mimeType =
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

    // Android-specific code
    if (Platform.isAndroid) {
      // Prepare for using the MediaStore
      final Directory? downloadsDirectory =
          await getExternalStorageDirectory(); // Deprecated API, consider using alternative
      String filePath = p.join(downloadsDirectory!.path, fileName);

      try {
        // Writing the file to the app's private external storage directory
        File file = File(filePath);
        await file.writeAsBytes(fileBytes);

        // TODO: For Android 10 and above, consider using MediaStore API to save to public Downloads
        print("File saved in private external storage: $filePath");
      } catch (e) {
        print("Failed to save file: $e");
      }
    } else {
      // iOS-specific code or other platforms
      // Note: iOS doesn't have a user-accessible file system like Android,
      // so consider using share_plus or similar package to share the file with other apps
      print("Platform not supported for direct file saving.");
    }
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      // Order of deletion matters if there are foreign key constraints.
      // Delete from 'journals' first because it has a foreign key from 'feelings'
      await txn.delete('journals');
      // Then, delete from 'feelings'
      await txn.delete('feelings');
    });
    print("All data deleted from the database.");
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
