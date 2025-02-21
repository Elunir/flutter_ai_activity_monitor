import 'dart:io';
import 'package:sqflite/sqflite.dart';

class DatabaseService {

  DatabaseService._init();
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // deleteDatabaseFile();
    _database = await _initDB('app_usage.db');
    return _database!;
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/app_usage.db';
    await deleteDatabase(path);
    print("✅ Database deleted successfully!");
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = File('$dbPath/$filePath');

    return await openDatabase(
      path.path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activity_logs (
          package_name TEXT PRIMARY KEY,  -- Set package_name as PRIMARY KEY
          duration INTEGER NOT NULL,
          timestamp TEXT DEFAULT CURRENT_TIMESTAMP
        )
        ''');
      },
    );
  }

  /// Inserts or updates app usage data based on timestamp
  Future<void> insertUsageData(String packageName, int duration) async {
    final db = await database;

    // Update if entry exists, otherwise insert new row
    await db.rawInsert('''
    INSERT INTO activity_logs (package_name, duration, timestamp)
    VALUES (?, ?, CURRENT_TIMESTAMP)
    ON CONFLICT(package_name) DO UPDATE 
    SET duration = duration + excluded.duration, timestamp = CURRENT_TIMESTAMP
    ''', [packageName, duration]);
  }

  /// Fetches usage data filtered by day, month, or year
  Future<List<Map<String, dynamic>>> fetchUsageData(String filterType) async {
    final db = await database;
    String timeFilter = '';

    switch (filterType) {
      case 'day':
        timeFilter = "DATE(timestamp) = DATE('now')";
        break;
      case 'month':
        timeFilter = "strftime('%Y-%m', timestamp) = strftime('%Y-%m', 'now')";
        break;
      case 'year':
        timeFilter = "strftime('%Y', timestamp) = strftime('%Y', 'now')";
        break;
      default:
        timeFilter = "DATE(timestamp) = DATE('now')";
    }

    return await db.query(
      'activity_logs',
      where: timeFilter,
      orderBy: 'timestamp DESC',
      limit: 10,
    );
  }
}
