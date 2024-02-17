import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'model/UploadData.dart';

class DatabaseHelper {
  static const String DB_NAME = "upload_queue.db";
  static const String TABLE_NAME = "uploads";

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var databasesPath = await getApplicationDocumentsDirectory();
    var path = [databasesPath.path, DB_NAME].join();

    return await openDatabase(path, version: 1, onCreate: (db, version) {
    //  db.execute("CREATE TABLE $TABLE_NAME (id INTEGER PRIMARY KEY AUTOINCREMENT, filePath TEXT, fileName TEXT, status TEXT)");
      db.execute(
          " CREATE TABLE IF NOT EXISTS $TABLE_NAME (id INTEGER PRIMARY KEY AUTOINCREMENT, ComplainID INTEGER, AttachmentTypeID INTEGER, filePath TEXT, fileName TEXT, status TEXT)");
    });
  }

  Future<int> insert(UploadData uploadData) async {
    final db = await database;
    return await db.insert(TABLE_NAME, uploadData.toJson());
  }

  Future<List<UploadData>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(TABLE_NAME);
    printInfo(info: maps.toString());
    return List.generate(maps.length, (i) => UploadData.fromJson(maps[i]));
  }
  Future<List<UploadData>> getAllPending() async {
    final db = await database;
  List<Map> maps = await db.query(TABLE_NAME,
          columns: ['*'],
          where: 'status = ?',
          whereArgs: ["Pending"]);
     printInfo(info: maps.toString());
    return List.generate(maps.length, (i) => UploadData.fromJson(maps[i]));
  }

  Future<void> update(UploadData uploadData) async {
    final db = await database;
    await db.update(TABLE_NAME, uploadData.toJson(),
        where: "id = ?", whereArgs: [uploadData.id]);
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete(TABLE_NAME, where: "id = ?", whereArgs: [id]);
  }
}
