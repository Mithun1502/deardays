import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dear_days/features/diary/data/diary_model.dart';

class LocalDataSource {
  static final LocalDataSource _instance = LocalDataSource._internal();
  factory LocalDataSource() => _instance;
  LocalDataSource._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dear_days.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE diary_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            dateTime TEXT NOT NULL,
            mood TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertEntry(DiaryModel entry) async {
    final db = await database;
    return await db.insert(
      'diary_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DiaryModel>> getAllEntries() async {
    final db = await database;
    final result = await db.query(
      'diary_entries',
      orderBy: 'dateTime DESC',
    );
    return result.map((map) => DiaryModel.fromMap(map)).toList();
  }

  Future<List<DiaryModel>> getFilteredEntries(
      {String? dateTime, String? mood}) async {
    final db = await database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (dateTime != null && dateTime.isNotEmpty) {
      whereClauses.add("dateTime LIKE ?");
      whereArgs.add('%$dateTime%');
    }

    if (mood != null && mood.isNotEmpty) {
      whereClauses.add("mood = ?");
      whereArgs.add(mood);
    }

    final result = await db.query(
      'diary_entries',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'dateTime DESC',
    );

    return result.map((map) => DiaryModel.fromMap(map)).toList();
  }

  Future<int> updateEntry(DiaryModel entry) async {
    final db = await database;
    return await db.update(
      'diary_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
