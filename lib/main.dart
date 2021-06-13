import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/db/db.dart';
import 'package:todo_app/providers/home_provider.dart';
import 'package:todo_app/providers/tasks_provider.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  initializeDateFormatting();
  await DB.createDB();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: TasksProvider()),
        ChangeNotifierProvider.value(value: HomeProvider()),
      ],
      child: BuildApp(),
    );
  }
}

class BuildApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        primaryColor: Colors.cyan[800],
        canvasColor: Colors.cyan[100],
        primaryTextTheme: TextTheme(bodyText1: TextStyle(color: Colors.black)),
        primaryIconTheme: IconThemeData(
          color: Colors.cyan[900],
        ),
        dividerColor: Colors.black54,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.cyan,
        primaryColor: Colors.cyan[500],
        canvasColor: Colors.cyan[800],
        primaryTextTheme: TextTheme(bodyText1: TextStyle(color: Colors.white)),
        primaryIconTheme: IconThemeData(
          color: Colors.blue[900],
        ),
        dividerColor: Colors.white54,
      ),
      themeMode: context.watch<HomeProvider>().themeMode,
      home: FutureBuilder(
        builder: (ctx, _) => FutureBuilder(
          future: context.watch<TasksProvider>().firstLoadTask
              ? null
              : context.read<TasksProvider>().getDataFromDB(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return snapshot.connectionState == ConnectionState.waiting
                ? SplashScreen()
                : HomeScreen();
          },
        ),
      ),
      supportedLocales: [
        Locale('en', 'US'),
      ],
    );
  }
}
