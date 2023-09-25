import 'package:get/get.dart';
import 'package:to_d/db/db_helper.dart';
import '../models/task.dart';

class TaskController extends GetxController {
  final taskList = <Task>[].obs;

  Future<void> getTasks() async {
    final tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  void deleteTasks(Task task) async {
    await DBHelper.delete(task);
    getTasks();
  }
  void deleteAllTasks() async {
    await DBHelper.deleteAll();
    getTasks();
  }

  void markIsComleted(int id) async {
    await DBHelper.update(id);
    getTasks();
  }

  Future<int> addTask({Task? task}) {
    return DBHelper.insert(task);
  }
}
