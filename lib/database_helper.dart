import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'model/feeling_model.dart'; // Import your Feeling model
import 'model/journal_model.dart'; // Import your Journal model

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
    print ("feeling");
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
    final result = await db.delete('journals', where: 'id = ?', whereArgs: [id]);
    return result;
  }



  Future close() async {
    final db = await instance.database;
    db.close();
  }


}
