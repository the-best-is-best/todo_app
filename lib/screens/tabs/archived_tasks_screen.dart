import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/component/tasks_list_view.dart';
import 'package:todo_app/providers/tasks_provider.dart';

class ArchivedTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return tasksListView(context.watch<TasksProvider>().tasksArchive, context);
  }
}
