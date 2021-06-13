import 'package:flutter/material.dart';
import 'package:todo_app/component/home_component.dart';
import 'package:todo_app/models/tasks_model.dart';

Widget tasksListView(List<TaskModel> task, BuildContext context) {
  return task.length == 0
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 80,
                color: Colors.grey,
              ),
              Text(
                "No Tasks Yet,  Please Add Some Tasks",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              )
            ],
          ),
        )
      : ListView.separated(
          itemBuilder: (context, i) {
            return buildTaskItem(task[i], context);
          },
          separatorBuilder: (context, i) {
            return Divider(
              height: 1,
            );
          },
          itemCount: task.length);
}
