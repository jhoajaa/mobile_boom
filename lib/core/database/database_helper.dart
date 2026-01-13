import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/boom/data/models/book_model.dart';

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
    String path = join(await getDatabasesPath(), 'boom_books_v2.db'); 
    return await openDatabase(
      path,
      version: 1, 
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books(
        book_id TEXT PRIMARY KEY,
        user_id TEXT,
        category_id TEXT,
        title TEXT,
        author TEXT,
        publisher TEXT,
        category_name TEXT,
        cover_image_url TEXT,
        status_baca TEXT,
        total_pages INTEGER,
        current_page INTEGER
      )
    ''');
  }

  Future<void> cacheBooks(List<BookModel> books) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('books');
      for (var book in books) {
        await txn.insert('books', book.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<BookModel>> getCachedBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');

    return List.generate(maps.length, (i) {
      return BookModel.fromMap(maps[i]);
    });
  }
}