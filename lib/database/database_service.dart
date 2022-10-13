import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  //single instance of this class
  static DatabaseService? _instance;

  //database info variables
  static Database? database;
  static const String dbName = 'data.db';
  static const int dbVersion = 1;

  //table and column info variables
  static const String tableName = 'activities';
  static const String columnId = 'columnId';
  static const String type = 'type';
  static const String data = 'data';
  static const String date = 'date';

  //Private constructor for this class
  DatabaseService._privateConstructor();

  //Factory constructor for maintaining only one instance of this class
  factory DatabaseService() {
    _instance ??= DatabaseService._privateConstructor();
    return _instance!;
  }

  //Getter function for getting the database
  Future<Database> get db async {
    if (database != null) {
      return database!;
    }
    database = await initializeDatabase();
    return database!;
  }

  //initialize the database and open it
  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, dbName);
    return await openDatabase(path, version: dbVersion, onCreate: createTable);
  }

  //create a table inside database when first initialized
  FutureOr<void> createTable(Database db, int version) {
    db.execute(''' 
        CREATE TABLE $tableName(
          $columnId INTEGER PRIMARY KEY,
          $type TEXT NOT NULL,
          $data REAL NOT NULL,
          $date TEXT NOT NULL
        )
    ''');
  }

  //Initializing database and then adding table to database followed by adding row to table
  Future<int> addActivity(Map<String, dynamic> row) async {
    //calling the getter function "db"
    Database database = await _instance!.db;
    return await database.insert(tableName, row);
  }

  //For getting information from rows/activites
  Future<List<Map<String, Object?>>> getActivities(String category) async {
    Database db = await _instance!.db;
    if (category == 'All') {
      return await db.rawQuery('SELECT * FROM $tableName');
    } else {
      return await db.rawQuery(
          'SELECT * FROM $tableName WHERE $type=?', [category.toLowerCase()]);
    }
  }

  Future<int> deleteActivity(int id) async {
    Database db = await _instance!.db;
    return await db.delete(tableName, where: 'columnId = ?', whereArgs: [id]);
  }
}
