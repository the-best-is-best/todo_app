import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/component/date_time_picker.dart';
import 'package:todo_app/component/form_field.dart';
import 'package:todo_app/models/tasks_model.dart';
import 'package:todo_app/providers/home_provider.dart';
import 'package:todo_app/providers/tasks_provider.dart';
import 'package:todo_app/screens/tabs/archived_tasks_screen.dart';
import 'package:todo_app/screens/tabs/done_tasks_screen.dart';
import 'package:todo_app/screens/tabs/tasks_screen.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> screens = [
    TasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  final List<String> titles = [
    'Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  late FlutterLocalNotificationsPlugin localNotifications;
  @override
  void initState() {
    Intl.defaultLocale = 'en';
    super.initState();

    var androidInitialize =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializeSettings =
        new InitializationSettings(android: androidInitialize);

    localNotifications = new FlutterLocalNotificationsPlugin();
    localNotifications.initialize(initializeSettings);
  }

  Future _showNotification(
      {required id, required desc, required DateTime dateTime}) async {
    var androidDetial = new AndroidNotificationDetails(
        id.toString(), "Finished todo", desc,
        importance: Importance.high);
    var generateNotificationDetails =
        new NotificationDetails(android: androidDetial);
    localNotifications.zonedSchedule(
        id,
        "Finished todo",
        desc,
        tz.TZDateTime.now(tz.local)
            .add(Duration(days: dateTime.day - DateTime.now().day))
            .add(Duration(hours: dateTime.hour - DateTime.now().hour))
            .add(Duration(minutes: dateTime.minute - DateTime.now().minute)),
        generateNotificationDetails,
        payload: id.toString(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime);
  }

  Future<void> notificationStart({
    required lastId,
    required DateTime dateTime,
    required TaskModel data,
    required BuildContext context,
  }) async {
    _showNotification(id: lastId, desc: data.title, dateTime: dateTime);
  }

  var titleController = TextEditingController();
  var dateTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          titles[context.watch<HomeProvider>().currentTab],
        ),
        actions: [
          PopupMenuButton(
              onSelected: (val) {
                if (val == 0) {
                  context
                      .read<HomeProvider>()
                      .changeThemeMode(ThemeMode.system);
                } else if (val == 1) {
                  context.read<HomeProvider>().changeThemeMode(ThemeMode.light);
                } else {
                  context.read<HomeProvider>().changeThemeMode(ThemeMode.dark);
                }
              },
              itemBuilder: (_) => [
                    PopupMenuItem(
                      height: 10,
                      child: Text("Theme Mode"),
                    ),
                    PopupMenuItem(
                      height: 10,
                      child: Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.grey,
                      ),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.restore),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text("System"),
                          ),
                        ],
                      ),
                      value: 0,
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.light_mode),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(child: Text("Light")),
                        ],
                      ),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.dark_mode),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(child: Text("Dark")),
                        ],
                      ),
                      value: 2,
                    ),
                  ])
        ],
      ),
      body: !context.watch<TasksProvider>().loadedTask
          ? Center(
              child: CircularProgressIndicator(),
            )
          : screens[context.watch<HomeProvider>().currentTab],
      floatingActionButton: FloatingActionButton(
        onPressed: !context.watch<TasksProvider>().loadedTask
            ? null
            : () {
                if (context.read<HomeProvider>().isBottomSheetShow) {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  formKey.currentState!.save();
                  Map<String, dynamic> data = {
                    'title': titleController.text,
                    'dateTime': dateTimeController.text.toString(),
                    'status': "new"
                  };
                  late int lastId;

                  context
                      .read<TasksProvider>()
                      .insertToDB(data)
                      .then((id) async {
                    lastId = id;
                    TaskModel newTask = TaskModel(lastId, data['title'],
                        DateTime.parse(data['dateTime']), "new");
                    context.read<TasksProvider>().addNewTask(newTask);

                    await notificationStart(
                        lastId: lastId,
                        dateTime: DateTime.parse(data['dateTime']),
                        data: newTask,
                        context: context);

                    Navigator.of(context).pop();
                    context.read<HomeProvider>().showHideBottomSheet();

                    titleController.text = "";
                    dateTimeController.text = "";
                  });
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  context: context,
                                  controller: titleController,
                                  type: TextInputType.text,
                                  validate: (String? val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Title must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'Task Title',
                                  prefix: Icons.title,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                defaultDateTimePicker(
                                    context: context,
                                    controller: dateTimeController,
                                    label: 'Task Date - time',
                                    validator: (String? val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Select Date / time';
                                      }
                                      return null;
                                    }),
                              ],
                            ),
                          ),
                        ),
                        elevation: 20,
                      )
                      .closed
                      .then((_) {
                    context.read<HomeProvider>().showHideBottomSheet();
                  });
                }
                context.read<HomeProvider>().showHideBottomSheet();
              },
        child: context.watch<TasksProvider>().loadedTask
            ? Icon(!context.watch<HomeProvider>().isBottomSheetShow
                ? Icons.edit
                : Icons.add)
            : CircularProgressIndicator(
                color: Colors.white,
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: !context.watch<TasksProvider>().loadedTask
            ? null
            : (val) {
                context.read<HomeProvider>().goNextTap(val);
              },
        currentIndex: context.watch<HomeProvider>().currentTab,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Tasks"),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline), label: "Done"),
          BottomNavigationBarItem(
              icon: Icon(Icons.archive_outlined), label: "Archived"),
        ],
      ),
    );
  }
}
