import 'dart:async';

import 'package:wave_weather/models/WeatherLocation.dart';
import 'package:wave_weather/controllers/PlaceController.dart';
import 'package:wave_weather/services/LocationHelper.dart';
import 'package:wave_weather/services/constants.dart';
import 'package:wave_weather/controllers/WeatherController.dart';
import 'package:get/get.dart';
import 'package:wave_weather/views/HomeScreen.dart';

import 'DBHelper.dart';
import 'NetworkHelper.dart';

class WeatherHelper {
  var _okStatus = 200;
  var latitude;
  var locationId;
  var longitude;
  var temperature;
  var condition;
  var cityName;
  var weatherDescription;
  var sunrise;
  var sunset;
  var feelLike;
  var maxTemperature;
  var minTemperature;
  var humidity;
  var pressure;
  var windSpeed;
  var windDirection;
  var weatherinfo;
  var dateTime;
  var timeZone;
  var country;
  DBHelper dbHelper = DBHelper();
  final WeatherController weatherController = Get.put(WeatherController());
  final PlaceController placeController = Get.put(PlaceController());
  final LocationHelper location = LocationHelper();
  Future<dynamic> getCurrentLocationWeather({latitude, longitude}) async {
    String request =
        '$kOpenWeatherUrl?lat=$latitude&lon=$longitude&appid=$kOpenWeatherApiKey&units=metric';
    NetworkHelper networkHelper = NetworkHelper(request);

    var weatherData = await networkHelper.getData();

    return weatherData;
  }

  //? is Update is used for updating , if it is true then updation will occur ,
  //? if it is false , it means that insertion will occur.

  doCurrentWeatherParseAndSave(
      {lat, long, required bool isUpdate, required String placeId}) async {
    assert(long != null);
    assert(lat != null);
    var weatherResult =
        await getCurrentLocationWeather(latitude: lat, longitude: long);
    var status = weatherResult['cod'];
    if (status == _okStatus) {
      await saveWeatherInDB(
          weatherResult: weatherResult, placeId: placeId, isUpdate: isUpdate);
    }
  }

  doWeatherParseAndSave(
      {required String placeId,
      required String city,
      required double lat,
      required double long,
      required bool isUpdate}) async {
    //? here we are getting the weather data by city
    var weatherResultCity = await getCityData(city);
    var status = weatherResultCity['cod'];
    if (status == _okStatus) {
      await saveWeatherInDB(
          weatherResult: weatherResultCity,
          placeId: placeId,
          isUpdate: isUpdate);
    }
    //? here we are getting the weather data by lat / long if by city is not possible.
    else {
      var weatherResultLatLng = await getWeatherByLatLng(lat: lat, lng: long);
      status = weatherResultLatLng['cod'];
      if (status == _okStatus) {
        await saveWeatherInDB(
            weatherResult: weatherResultLatLng,
            placeId: placeId,
            isUpdate: isUpdate);
        return;
      }
    }
  }

  Future<dynamic> getCityData(String typedName) async {
    typedName = typedName.replaceAll(', ', ',');
    NetworkHelper networkHelper = NetworkHelper(
        '$kOpenWeatherUrl?q=$typedName&appid=$kOpenWeatherApiKey&units=metric');
    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  Future<dynamic> getWeatherByLatLng(
      {required double lat, required double lng}) async {
    NetworkHelper networkHelper = NetworkHelper(
        '$kOpenWeatherUrl?lat=$lat&lon=$lng&appid=$kOpenWeatherApiKey&units=metric');
    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  saveWeatherInDB(
      {var weatherResult,
      required String placeId,
      required bool isUpdate}) async {
    await parseDataInWeather(
        weatherData: weatherResult, placeId: placeId, isUpdate: isUpdate);
    await placeController.refreshPLaceId();
    return;
  }

  parseDataInWeather(
      {var weatherData,
      required String placeId,
      required bool isUpdate}) async {
    latitude = weatherData['coord']['lat'];
    longitude = weatherData['coord']['lon'];
    temperature = weatherData['main']['temp'].toString();
    condition = weatherData['weather'][0]['id'].toString();
    cityName = weatherData['name'].toString();
    weatherDescription = weatherData['weather'][0]['description'];
    locationId = weatherData['id'];
    timeZone = weatherData['timezone'].toString();
    //sunrise and sunset , we get them in utc format.
    sunrise = weatherData['sys']['sunrise'].toString();
    sunset = weatherData['sys']['sunset'].toString();
    feelLike = weatherData['main']['feels_like'].toString();
    maxTemperature = weatherData['main']['temp_max'].toString();
    minTemperature = weatherData['main']['temp_min'].toString();
    humidity = weatherData['main']['humidity'];
    pressure = weatherData['main']['pressure'].toString();
    windSpeed = weatherData['wind']['speed'].toString();
    windDirection = weatherData['wind']['deg'].toString();
    weatherinfo = weatherData['weather'][0]['main'].toString();
    country = weatherData['sys']['country'];
    dateTime = getCurrentTime();
    WeatherLocation weatherCity = WeatherLocation(
        country: country,
        timeZone: timeZone,
        placeId: placeId,
        city: cityName,
        dateTime: dateTime,
        temperature: temperature,
        weatherType: weatherinfo,
        windSpeed: windSpeed,
        windDirection: windDirection,
        humidity: humidity,
        pressure: pressure,
        feelLike: feelLike,
        maxTemperature: maxTemperature,
        minTemperature: minTemperature,
        sunRise: sunrise,
        sunSet: sunset,
        condition: condition,
        weatherDescription: weatherDescription,
        latitude: double.tryParse(latitude.toString())!,
        longitude: double.tryParse(longitude.toString())!,
        locationId: locationId);
    if (isUpdate) {
      await dbHelper.updateWeather(weatherCity).catchError((e) {
        print(e.toString());
      });
    } else {
      await dbHelper.insertWeather(weatherCity).catchError((e) {
        print(e.toString());
      });
    }
    await weatherController.doUpdate();
    if (weatherController.count.value == 1) {
      Get.offAll(HomeScreen(
        dotCount: 1,
      ));
    }
  }

  String timeString = '';

  getUtcTime({required String time, required String timezoneTemp}) {
    // String timeString = '';
    double timeZone = double.parse(timezoneTemp);
    if (timeZone > 0) {
      timeString = "+" + (timeZone ~/ 3600).toString();
    } else {
      timeString = (timeZone ~/ 3600).toString();
    }
    DateTime uctTime = DateTime.fromMillisecondsSinceEpoch(
            (int.parse(time) + int.parse(timeString)) * 1000)
        .toUtc();
    return uctTime;
  }

  String convertTime(String time, String timezoneTemp) {
    String localTime = '';
    DateTime uctTime = getUtcTime(time: time, timezoneTemp: timezoneTemp);

    if (uctTime.hour >= 12) {
      if (uctTime.minute < 10) {
        localTime =
            '0${(uctTime.hour + int.parse(timeString)) % 12}: 0${uctTime.minute} pm';
      } else {
        localTime =
            '${(uctTime.hour + int.parse(timeString)) % 12}:${uctTime.minute} pm';
      }
    } else {
      if (uctTime.minute < 10) {
        localTime =
            '${(uctTime.hour + int.parse(timeString))}: 0${uctTime.minute} am';
      } else {
        localTime =
            '${(uctTime.hour + int.parse(timeString))}:${uctTime.minute} am';
      }
    }
    return localTime;
  }

  bool checkDay(
      {required String sunset,
      required String timeZone,
      required String sunrise}) {
    DateTime currentTime = DateTime.now();
    DateTime sunsetTime = getUtcTime(time: sunset, timezoneTemp: timeZone);
    DateTime sunriseTime = getUtcTime(time: sunrise, timezoneTemp: timeZone);

    //?here we are checking time for daylight
    //? formula for daylight is (currentTime >= sunRise) &&( currrentTime <=sunSet)
    if (((sunsetTime.hour + int.parse(timeString)) >= (currentTime.hour)) &&
        (sunriseTime.hour + int.parse(timeString)) <= (currentTime.hour)) {
      if ((sunriseTime.minute <= currentTime.minute) ||
          (sunsetTime.minute >= currentTime.minute)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  String getCurrentTime() {
    DateTime uctTime = DateTime.now();
    return uctTime.toString();
  }
}
