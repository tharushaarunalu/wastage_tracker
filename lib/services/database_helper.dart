import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/wastage_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'wastage_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wastage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        weight REAL,
        date TEXT
      )
    ''');
  }

  Future<int> insertWastage(WastageItem item) async {
    final db = await database;
    return await db.insert('wastage', item.toMap());
  }

  Future<List<WastageItem>> getWastagesByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'wastage',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfDay, endOfDay],
    );

    return maps.map((map) => WastageItem.fromMap(map)).toList();
  }

  Future<int> deleteWastage(int id) async {
    final db = await database;
    return await db.delete('wastage', where: 'id = ?', whereArgs: [id]);
  }
}
