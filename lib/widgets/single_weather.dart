import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:wave_weather/controllers/WeatherController.dart';
import 'package:wave_weather/models/WeatherLocation.dart';
import 'package:wave_weather/services/HelperFunctions.dart';
import 'package:wave_weather/services/constants.dart';
import 'package:wave_weather/services/weatherHelper.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_icons/weather_icons.dart';

class SingleWeather extends StatelessWidget {
  SingleWeather({required this.weatherLocation, required this.isUnit});

  final bool fade = false;
  final bool isUnit;
  final ScrollController scrollController = ScrollController();
  final WeatherController weatherController =
      Get.find(tag: 'weatherController');

  final WeatherHelper weatherHelper = WeatherHelper();
  //Fields for Single Weather

  final WeatherLocation weatherLocation;

  updatedAt() {
    DateTime dateTime = DateTime.parse(weatherLocation.dateTime);
    String localTime = '';
    DateTime timeNow = DateTime.now();
    var diff = timeNow.difference(dateTime);

    if (diff.inHours >= 1) {
      if (diff.inHours == 1) {
        localTime = '${diff.inHours} hour ago';
      } else {
        localTime = '${diff.inHours} hours ago';
      }
    } else if (diff.inMinutes >= 1) {
      localTime = '${diff.inMinutes} min ago';
    } else {
      localTime = '${diff.inSeconds} sec ago';
    }
    return localTime;
  }

  convertUtcToLocalTime({var time, var timezone}) {
    return weatherHelper.convertTime(time, timezone);
  }

  getWeatherIcon(var condition, var sunset, var timeZone, var sunrise) {
    IconData? _weatherinfo;
    if (condition <= 232 && condition >= 200) {
      _weatherinfo = WeatherIcons.thunderstorm;
    } else if (condition <= 321 && condition >= 300) {
      _weatherinfo = WeatherIcons.showers;
    } else if (condition == 511) {
      _weatherinfo = WeatherIcons.snowflake_cold;
    } else if (condition <= 531 && condition >= 505) {
      _weatherinfo = WeatherIcons.rain;
    } else if (condition <= 504 && condition >= 500) {
      _weatherinfo = WeatherIcons.day_rain;
    } else if (condition <= 622 && condition >= 600) {
      _weatherinfo = WeatherIcons.snowflake_cold;
    } else if (condition < 800 && condition >= 701) {
      if (condition == 711) {
        _weatherinfo = WeatherIcons.smoke;
      } else if (condition == 761) {
        _weatherinfo = WeatherIcons.dust;
      } else if (condition == 781) {
        _weatherinfo = WeatherIcons.tornado;
      } else if (condition == 751) {
        _weatherinfo = WeatherIcons.sandstorm;
      } else {
        _weatherinfo = WeatherIcons.fog;
      }
    } else if (condition == 800) {
      if (weatherHelper.checkDay(
          sunrise: sunrise, sunset: sunset, timeZone: timeZone)) {
        _weatherinfo = WeatherIcons.day_sunny;
      } else {
        _weatherinfo = WeatherIcons.night_clear;
      }
    } else if (condition >= 801 && condition <= 804) {
      if (weatherHelper.checkDay(
          sunrise: sunrise, sunset: sunset, timeZone: timeZone)) {
        _weatherinfo = WeatherIcons.day_cloudy;
      } else {
        _weatherinfo = WeatherIcons.night_alt_cloudy;
      }
    }
    return _weatherinfo;
  }

  convertToInt(String value) {
    //converting string to double because sometimes value is a double type
    //then double is converted to int and returned as a string
    int convertedValue = double.parse(value).toInt();
    return convertedValue.toString();
  }

  getSavedSelectedUnits() async {
    String? selectTemperature;
    String? selectWind;
    await HelperFunctions.getTemperatureUnit().then((value) {
      selectTemperature = value;
    });
    await HelperFunctions.getWindUnit().then((value) {
      selectWind = value;
    });

    //? here we are checking for null then we automatically save defaut unit
    if (selectTemperature == null) {
      selectTemperature = kTemperatureMenuItems[0];
      weatherController.saveTempUnit(1);
    }
    //? here we are checking for null then we automatically save defaut unit
    if (selectWind == null) {
      selectWind = kWindMenuItems[0];
      weatherController.saveWindUnit(1);
    }
    //? if values are not null , then
    if (selectTemperature == kTemperatureMenuItems[0]) {
      //? 1 means that temperature is Celcius
      weatherController.saveTempUnit(1);
    } else {
      //? 2 means that temperature is Fahrenheit
      weatherController.saveTempUnit(2);
      weatherController.doUpdate();
    }

    if (selectWind == kWindMenuItems[0]) {
      //? 1 means that wind speed is Kmh
      weatherController.saveWindUnit(1);
    } else {
      //? 1 means that wind speed is MPH
      weatherController.saveWindUnit(2);
    }
  }

  getTemperatureByUnit(var temperature) {
    getSavedSelectedUnits();
    double tempByUnit;
    if (weatherController.isTempUnitCelcius.value) {
      tempByUnit = double.parse(temperature);
    } else {
      tempByUnit = (double.parse(temperature) * (1.8)) + 32;
    }
    int convertedValue = tempByUnit.toInt();
    return convertedValue.toString();
  }

  getTemperatureIcon() {
    var temperatureIcon;
    if (weatherController.isTempUnitCelcius.value) {
      temperatureIcon = WeatherIcons.celsius;
    } else {
      temperatureIcon = WeatherIcons.fahrenheit;
    }
    return temperatureIcon;
  }

  getWindByUnit(var wind) {
    getSavedSelectedUnits();
    String windValue;
    if (weatherController.isWindUnitKmh.value) {
      windValue = double.parse(wind).toStringAsPrecision(2) + ' km/h';
    } else {
      windValue =
          (double.parse(wind) * (1.609)).toStringAsPrecision(2) + ' mph';
    }
    return windValue;
  }

  Padding buildGlassContainer({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 3),
          child: Container(
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.37)),
            child: Padding(padding: const EdgeInsets.all(10.0), child: child),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double _scrollPosition;
    _scrollListener() {
      _scrollPosition = scrollController.position.pixels;

      if (_scrollPosition >= 20) {
        //? 1 means true here
        weatherController.saveFade(1);
      } else {
        //? here we are saving fade as false
        weatherController.saveFade(2);
      }
    }

    scrollController.addListener(_scrollListener);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.only(
        top: 20,
        left: 25,
        right: 25,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
        child: Container(
          padding: EdgeInsets.only(bottom: Get.height * 0.09),

          child: ListView(
            physics: BouncingScrollPhysics(),
            controller: scrollController,
            primary: false,
            shrinkWrap: true,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: Get.height * 0.020,
                      ),

                      AutoSizeText(
                        weatherLocation.city,
                        maxLines: 2,
                        style: GoogleFonts.lato(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Obx(() => Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    getTemperatureByUnit(
                                        weatherLocation.temperature),
                                    maxLines: 2,
                                    style: GoogleFonts.lato(
                                      fontSize: 60,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  BoxedIcon(
                                    getTemperatureIcon(),
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ],
                              ))),
                      // BoxedIcon(WeatherIcons.celsius),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BoxedIcon(
                              getWeatherIcon(
                                  int.tryParse(weatherLocation.condition),
                                  weatherLocation.sunSet,
                                  weatherLocation.timeZone,
                                  weatherLocation.sunRise),
                              color: Colors.white,
                              size: 40,
                            ),
                            AutoSizeText(
                              weatherLocation.weatherDescription.capitalize,
                              maxLines: 2,
                              style: GoogleFonts.lato(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Get.height * 0.05,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: Get.width * 0.28,
                            height: Get.height * 0.048,
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          AutoSizeText(
                            'Updated ${(updatedAt())}',
                            maxLines: 2,
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Divider(
                    thickness: 2,
                  ),
                  buildGlassContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              'Wind',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            Obx(() => Row(
                                  children: [
                                    WindIcon(
                                      degree: double.tryParse(
                                          weatherLocation.windDirection)!,
                                      color: Colors.white,
                                    ),
                                    AutoSizeText(
                                      getWindByUnit(weatherLocation.windSpeed),
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ))
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText(
                              'Humidy',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            AutoSizeText(
                              '${weatherLocation.humidity.toString()} %',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //here
              buildGlassContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            AutoSizeText(
                              'Sunrise',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            Row(
                              children: [
                                BoxedIcon(
                                  WeatherIcons.sunrise,
                                  color: Colors.white,
                                ),
                                AutoSizeText(
                                  convertUtcToLocalTime(
                                    time: weatherLocation.sunRise,
                                    timezone: weatherLocation.timeZone,
                                  ),
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            AutoSizeText(
                              'Sunset',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            Row(
                              children: [
                                BoxedIcon(
                                  WeatherIcons.sunset,
                                  color: Colors.white,
                                ),
                                AutoSizeText(
                                  convertUtcToLocalTime(
                                    time: weatherLocation.sunSet,
                                    timezone: weatherLocation.timeZone,
                                  ),
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ), //sunrise and sunset Row ends here
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, right: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              AutoSizeText(
                                'Real Feel',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              Obx(() => Row(
                                    children: [
                                      AutoSizeText(
                                        getTemperatureByUnit(
                                            weatherLocation.feelLike),
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      BoxedIcon(
                                        getTemperatureIcon(),
                                        color: Colors.white,
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                          Column(
                            children: [
                              AutoSizeText(
                                'Pressure',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    '${weatherLocation.pressure} hPa',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, right: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              AutoSizeText(
                                'Max Temp',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              Obx(() => Row(
                                    children: [
                                      AutoSizeText(
                                        getTemperatureByUnit(
                                            weatherLocation.maxTemperature),
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      BoxedIcon(
                                        getTemperatureIcon(),
                                        color: Colors.white,
                                      )
                                    ],
                                  ))
                            ],
                          ),
                          Column(
                            children: [
                              AutoSizeText(
                                'Min Temp',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              Obx(() => Row(
                                    children: [
                                      AutoSizeText(
                                        getTemperatureByUnit(
                                            weatherLocation.minTemperature),
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      BoxedIcon(
                                        getTemperatureIcon(),
                                        color: Colors.white,
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              buildGlassContainer(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText(
                              'Lat / Long',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            Row(
                              children: [
                                AutoSizeText(
                                  '${weatherLocation.latitude.toPrecision(2)} / ${weatherLocation.longitude.toPrecision(2)}',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText(
                              'Country',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            AutoSizeText(
                              weatherLocation.country,
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
