import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    int? totalExecutions;
    final sharedPreference = await SharedPreferences.getInstance();

    try {
      totalExecutions = sharedPreference.getInt("totalExecutions");

      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(seconds: 1));
        await sharedPreference.setInt("totalExecutions",
            totalExecutions == null ? 1 : totalExecutions + 1);
        totalExecutions = sharedPreference.getInt("totalExecutions");
      }
    } catch (err) {
      Logger().e(err
          .toString()); // Logger flutter package, prints error on the debug console
      throw Exception(err);
    }
    //print("Native called background task: $backgroundTask"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await SharedPreferences.getInstance();
  Workmanager().registerOneOffTask("task-identifier", "simpleTask");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BackgroundTaskUI(),
    );
  }
}

class BackgroundTaskUI extends StatefulWidget {
  const BackgroundTaskUI({Key? key}) : super(key: key);

  @override
  State<BackgroundTaskUI> createState() => _BackgroundTaskUIState();
}

class _BackgroundTaskUIState extends State<BackgroundTaskUI> {
  String numberText = "";

  _init() async {
    await Future.delayed(const Duration(seconds: 3));
    var sharedPreference = await SharedPreferences.getInstance(); //
    numberText = sharedPreference.getInt("totalExecutions").toString();
    print("NUMBER :$numberText");
    setState(() {});
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Background"),
      ),
      body: Center(
        child: Text(
          numberText,
          style: const TextStyle(
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}
