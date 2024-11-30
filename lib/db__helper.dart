import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Announcement {
  final int? id;
  final String title;
  final String description;
  final String date;
  final String author;

  Announcement({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.author,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'author': author,
    };
  }

  static Announcement fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      author: map['author'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('announcements.db');
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
      CREATE TABLE announcements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        author TEXT NOT NULL
      )
    ''');
  }

  Future<int> createAnnouncement(Announcement announcement) async {
    final db = await instance.database;
    return await db.insert('announcements', announcement.toMap());
  }

  Future<List<Announcement>> getAllAnnouncements() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'announcements',
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) => Announcement.fromMap(maps[i]));
  }

  Future<int> deleteAnnouncement(int id) async {
  final db = await instance.database;
  return await db.delete(
    'announcements',
    where: 'id = ?',
    whereArgs: [id],
  );
}
}