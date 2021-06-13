import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/models/tasks_model.dart';

class DB with ChangeNotifier {
  static late Database db;

  static Future<void> createDB() async {
    db = await openDatabase('todo.db', version: 1,
            onCreate: (database, version) {
      database.execute(
          'CREATE TABLE tasks (id integer PRIMARY KEY , title Text , dateTime TEXT , status Text)');
    }, onOpen: (database) {})
        .catchError((error) {});
  }

  static Future insertToDB({required String tableName, required data}) async {
    await db.transaction((txn) {
      return Future.delayed(Duration(seconds: 1), () async {
        return txn.insert(tableName, data).then((value) {
          return value;
        }).catchError((onError) {});
      });
    });
  }

  static Future<List<Map>> getDataFromDB(table) {
    List<Map<dynamic, dynamic>> data = [];
    return Future.delayed(Duration(seconds: 1), () async {
      data = await db.query(table);
      return data;
    });
  }

  static Future getLastId({required table}) async {
    var data =
        await db.rawQuery("SELECT * FROM $table ORDER BY id DESC LIMIT 1");
    return data[0]['id'];
  }

  static Future<int> updateData({
    required table,
    required TaskModel data,
  }) async {
    return Future.delayed(Duration(seconds: 1), () async {
      return await db
          .update(table, data.toMap(), where: 'id = ?', whereArgs: [data.id]);
    });
  }

  static Future deleteData<int>(
      {required String table, required int id}) async {
    return Future.delayed(Duration(seconds: 1), () async {
      return await db.delete(table, where: 'id = ?', whereArgs: [id]);
    });
  }
}
