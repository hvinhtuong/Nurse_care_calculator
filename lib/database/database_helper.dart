import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/history_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nurse_care.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tool_name TEXT NOT NULL,
        input_data TEXT NOT NULL,
        result TEXT NOT NULL,
        created_time TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertHistory(HistoryItem item) async {
    final db = await instance.database;
    return await db.insert('history', item.toMap());
  }

  Future<List<HistoryItem>> getAllHistory() async {
    final db = await instance.database;
    final result = await db.query('history', orderBy: 'id DESC');
    return result.map((json) => HistoryItem.fromMap(json)).toList();
  }

  // Xóa toàn bộ lịch sử
  Future<int> clearHistory() async {
    final db = await instance.database;
    return await db.delete('history');
  }

  // Xóa lịch sử theo ID
  Future<int> deleteHistoryById(int id) async {
    final db = await instance.database;
    return await db.delete(
      'history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}