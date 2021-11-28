import 'package:wave_weather/models/WeatherLocation.dart';
import 'package:get/state_manager.dart';

import '../services/DBHelper.dart';

class WeatherController extends GetxController {
  var count = 0.obs;
  var isTempUnitCelcius = true.obs;
  var isWindUnitKmh = true.obs;
  var indexWeather = 0.obs;
  var isFade = false.obs;

  var weatherList = <WeatherLocation>[].obs;

  DBHelper dbHelper = DBHelper();
  @override
  void onInit() {
    super.onInit();
    doUpdate();
  }

  reset() {
    indexWeather.value = 0;
    isTempUnitCelcius.value = true;
    isFade.value = false;
  }

  setCurrentWeatherIndex(var index) {
    indexWeather.value = index;
  }

  doUpdate() async {
    await getWeather();
    await getCount();
  }

  getCount() async {
    await dbHelper.getCount().then((value) {
      count.value = value;
    });
  }

  doSaveUnits() {
    saveTempUnit(1);
    saveWindUnit(1);
  }

  saveTempUnit(int checkButton) {
    // here 1 is used to identify the metric button
    if (checkButton == 1) {
      isTempUnitCelcius.value = true;
    }
    // here any number is used to identify the Imperial button
    else {
      isTempUnitCelcius.value = false;
    }
  }

  saveWindUnit(int checkButton) {
    // here 1 is used to identify the metric button
    if (checkButton == 1) {
      isWindUnitKmh.value = true;
    }
    // here any number is used to identify the Imperial button
    else {
      isWindUnitKmh.value = false;
    }
  }

  saveFade(int checkButton) {
    //? here 1 is used for fade true

    if (checkButton == 1) {
      isFade.value = true;
    }
    //? here any number means fade is false

    else {
      isFade.value = false;
    }
  }

  getWeather() async {
    var result = await dbHelper.getWeatherLocationList();
    return weatherList.assignAll(result);
  }
}
