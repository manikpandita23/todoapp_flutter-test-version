import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  late Database _database;

  Future<Database> get database async {
    _database = await initDatabase();
    return _database;
  }



  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          '''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task TEXT,
            is_completed INTEGER
          )
          ''',
        );
      },
    );
  }

  Future<void> insertTodo(Map<String, dynamic> todo) async {
    final Database db = await database;
    await db.insert('todos', todo, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getTodos() async {
    final Database db = await database;
    return await db.query('todos');
  }

  Future<void> updateTodo(Map<String, dynamic> todo) async {
    final Database db = await database;
    await db.update(
      'todos',
      todo,
      where: 'id = ?',
      whereArgs: [todo['id']],
    );
  }

  Future<void> deleteTodo(int id) async {
    final Database db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
