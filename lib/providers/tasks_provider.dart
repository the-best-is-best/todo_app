import 'package:flutter/foundation.dart';
import 'package:todo_app/db/db.dart';
import 'package:todo_app/models/tasks_model.dart';

class TasksProvider with ChangeNotifier {
  List<TaskModel> tasks = [];
  List<TaskModel> tasksNew = [];
  List<TaskModel> tasksDone = [];
  List<TaskModel> tasksArchive = [];

  bool firstLoadTask = false;
  bool loadedTask = false;

  void getData(List<Map> dbTasks) {
    List.generate(dbTasks.length, (i) {
      tasks.add(TaskModel(dbTasks[i]['id'], dbTasks[i]['title'],
          DateTime.parse(dbTasks[i]['dateTime']), dbTasks[i]['status']));

      if (dbTasks[i]['status'] == 'new') {
        tasksNew.add(TaskModel(dbTasks[i]['id'], dbTasks[i]['title'],
            DateTime.parse(dbTasks[i]['dateTime']), dbTasks[i]['status']));
      } else if (dbTasks[i]['status'] == "done") {
        tasksDone.add(TaskModel(dbTasks[i]['id'], dbTasks[i]['title'],
            DateTime.parse(dbTasks[i]['dateTime']), dbTasks[i]['status']));
      } else {
        tasksArchive.add(TaskModel(dbTasks[i]['id'], dbTasks[i]['title'],
            DateTime.parse(dbTasks[i]['dateTime']), dbTasks[i]['status']));
      }
    });

    notifyListeners();
  }

  void addNewTask(TaskModel task) {
    tasks.add(task);
    tasksNew.add(task);
    loadedTask = true;
    notifyListeners();
  }

  Future getDataFromDB() async {
    if (!firstLoadTask) {
      List<Map<dynamic, dynamic>> data = await DB.getDataFromDB('tasks');
      getData(data);
      loadedTask = true;
      firstLoadTask = true;
      notifyListeners();
    }
  }

  Future<int> insertToDB(data) async {
    loadedTask = false;
    notifyListeners();
    late int lastId;

    return await DB.insertToDB(tableName: 'tasks', data: data).then((_) {
      lastId = tasks.length > 0 ? tasks[tasks.length - 1].id + 1 : 1;

      return lastId;
    });
  }

  Future updateToDB(
      {required TaskModel data, required status, required int id}) async {
    loadedTask = false;
    notifyListeners();
    if (data.status == "new") {
      tasksNew.remove(data);
    } else if (data.status == "done") {
      tasksDone.remove(data);
    } else {
      tasksArchive.remove(data);
    }
    data.status = status;

    await DB.updateData(
      table: 'tasks',
      data: data,
    );
    var getTask = tasks.firstWhere((task) => task.id == id);
    getTask.status = status;
    if (getTask.status == "done") {
      tasksDone.add(data);
    } else {
      tasksArchive.add(data);
    }
    loadedTask = true;
    notifyListeners();
  }

  Future deleteFromDB(int id) async {
    loadedTask = false;
    notifyListeners();

    await DB.deleteData(table: 'tasks', id: id);
    var getTask = tasks.firstWhere((task) => task.id == id);
    if (getTask.status == "new") {
      tasksNew.removeWhere((taskId) => taskId.id == id);
    } else if (getTask.status == "done") {
      tasksDone.removeWhere((taskId) => taskId.id == id);
    } else {
      tasksArchive.removeWhere((taskId) => taskId.id == id);
    }
    tasks.remove(getTask);
    loadedTask = true;
    notifyListeners();
  }

  TaskModel task(id) {
    return tasks[id];
  }
}
