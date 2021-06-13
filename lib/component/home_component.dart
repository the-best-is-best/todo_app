import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/tasks_model.dart';
import 'package:todo_app/providers/tasks_provider.dart';

Widget buildTaskItem(TaskModel tasks, BuildContext context) => Dismissible(
      key: Key(tasks.id.toString()),
      onDismissed: (dirction) {
        context.read<TasksProvider>().deleteFromDB(tasks.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              child: Center(
                child: Text(
                  DateFormat.jm().format(tasks.dateTime),
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tasks.title,
                    style: Theme.of(context).primaryTextTheme.bodyText1,
                  ),
                  Text(
                    DateFormat.MMMEd().format(tasks.dateTime),
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: IconButton(
                onPressed: () => context
                    .read<TasksProvider>()
                    .updateToDB(status: 'done', data: tasks, id: tasks.id),
                icon: Icon(Icons.check_circle),
                color: Colors.green,
              ),
            ),
            IconButton(
              onPressed: () => context
                  .read<TasksProvider>()
                  .updateToDB(status: 'archived', data: tasks, id: tasks.id),
              icon: Icon(Icons.archive),
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
