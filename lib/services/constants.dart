import 'package:get/get.dart';
import 'package:wave_weather/controllers/WeatherController.dart';

const kPlacesApiKey = 'Enter Your place Api Key here';
const kPlaceApiBaseURL =
    'https://maps.googleapis.com/maps/api/place/autocomplete/json';
const kOpenWeatherApiKey = '9104a029b989117877de2f9d6f9fbe40';
const kOpenWeatherUrl = 'https://api.openweathermap.org/data/2.5/weather';
const kLocationPlaceID = 'placeId';
const kUnitMatic = 'metric';
const kUnitImperial = 'imperial';
const kTemperatureMenuItems = <String>['C', 'F'];
const kWindMenuItems = <String>[
  'Kilometers per hour (km/h)',
  'Miles per hour (mph)'
];
checkWeatherForEmpty() async {
  final WeatherController weatherController = Get.put(WeatherController());
  await weatherController.doUpdate();
  var result = weatherController.count.value;
  return result;
}
