import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('music_app.db');
    return _database!;
  }

  // inisialisasi database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // fungsi untuk create tabel users, songs dan insert data users
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        name TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        singer TEXT,
        genre TEXT
      )
    ''');

    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['admin'],
    );

    if (result.isEmpty) {
      await db.insert('users', {
        'username': 'admin',
        'name': 'Admin Happy Puppy',
        'password': 'admin',
      });
    }
  }
}
