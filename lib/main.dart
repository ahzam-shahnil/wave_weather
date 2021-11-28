import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wave_weather/services/constants.dart';
import 'package:wave_weather/services/AdManager.dart';
import 'package:wave_weather/views/CityScreen.dart';
import 'package:wave_weather/views/HomeScreen.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var res = await checkWeatherForEmpty();
  initializeFlutterFire();

  runApp(MyApp(
    count: res,
  ));
}

// Define an async function to initialize FlutterFire
void initializeFlutterFire() async {
  try {
    // Wait for Firebase to initialize and set `_initialized` state to true
    await Firebase.initializeApp();
    FirebaseAdMob.instance.initialize(appId: AdManager.appId);
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final count;
  const MyApp({this.count});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wave Weather',
      theme: ThemeData.light().copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme:
            AppBarTheme(color: Colors.black, shadowColor: Colors.transparent),
      ),
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark().copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme:
            AppBarTheme(color: Colors.black, shadowColor: Colors.transparent),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: count == 0
          ? CityScreen()
          : HomeScreen(
              dotCount: count,
            ),
    );
  }
}
