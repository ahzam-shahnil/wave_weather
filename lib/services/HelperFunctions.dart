import 'package:wave_weather/services/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  //here bool is true for we have set the unit to imperial
  static String temperatureUnit = kTemperatureMenuItems[0];
  static String windUnit = kWindMenuItems[0];
  static String isOk = 'true';
  //SAVING DATA TO SHARED PREFERENCE
  static Future<bool> saveFirst(bool isFirst) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(isOk, isFirst);
  }

  static Future<bool?> getIsFirst() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(isOk);
  }

  //SAVING DATA TO SHARED PREFERENCE
  static Future<bool> saveSelectedTempUnit(String selectedTempUnit) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(temperatureUnit, selectedTempUnit);
  }

  static Future<String?> getTemperatureUnit() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(temperatureUnit);
  }

  //SAVING DATA TO SHARED PREFERENCE
  static Future<bool> saveWindUnit(String selectedWindUnit) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(windUnit, selectedWindUnit);
  }

  static Future<String?> getWindUnit() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(windUnit);
  }
}
