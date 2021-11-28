import 'dart:ui';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wave_weather/models/WeatherLocation.dart';
import 'package:wave_weather/services/LocationHelper.dart';
import 'package:wave_weather/services/AdManager.dart';
import 'package:wave_weather/services/constants.dart';
import 'package:wave_weather/services/weatherHelper.dart';
import 'package:wave_weather/views/SettingsScreen.dart';
import 'package:wave_weather/views/CityScreen.dart';
import 'package:wave_weather/services/DBHelper.dart';
import 'package:wave_weather/controllers/WeatherController.dart';
import 'package:flutter_weather_bg/flutter_weather_bg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../widgets/single_weather.dart';

class HomeScreen extends StatefulWidget {
  final int dotCount;
  static bool toRefresh = true;
  HomeScreen({
    required this.dotCount,
  });
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DBHelper dbHelper = DBHelper();

  final WeatherController weatherController =
      Get.put(WeatherController(), permanent: true, tag: 'weatherController');

  PageController _pageController = PageController(initialPage: 0);
  final WeatherHelper weatherHelper = WeatherHelper();

  RefreshController _refreshController =
      RefreshController(initialRefresh: HomeScreen.toRefresh);
  bool isConnected = false;
  var listener;
  final ams = AdManager();

  Position? locationResponse;
  final LocationHelper locationHelper = LocationHelper();

  getdotCount() {
    return checkWeatherForEmpty();
  }

  getWeatherBackground({var value, var sunset, var timeZone, var sunrise}) {
    WeatherType? weatherType;
    int condition = int.tryParse(value)!;

    if (condition <= 232 && condition >= 200) {
      weatherType = WeatherType.thunder;
    } else if (condition <= 321 && condition >= 300) {
      weatherType = WeatherType.middleRainy;
    } else if (condition == 511) {
      weatherType = WeatherType.middleSnow;
    } else if (condition <= 531 && condition >= 505) {
      weatherType = WeatherType.heavyRainy;
    } else if (condition <= 504 && condition >= 500) {
      weatherType = WeatherType.heavyRainy;
    } else if (condition <= 622 && condition >= 600) {
      weatherType = WeatherType.heavySnow;
    } else if (condition < 800 && condition >= 701) {
      if (condition == 711) {
        weatherType = WeatherType.hazy;
      } else if (condition == 761) {
        weatherType = WeatherType.dusty;
      } else if (condition == 781) {
        weatherType = WeatherType.thunder;
      } else if (condition == 751) {
        weatherType = WeatherType.dusty;
      } else {
        weatherType = WeatherType.foggy;
      }
    } else if (condition == 800) {
      if (weatherHelper.checkDay(
          sunrise: sunrise, sunset: sunset, timeZone: timeZone)) {
        weatherType = WeatherType.sunny;
      } else {
        weatherType = WeatherType.sunnyNight;
      }
    } else if (condition >= 801 && condition <= 804) {
      if (weatherHelper.checkDay(
          sunrise: sunrise, sunset: sunset, timeZone: timeZone)) {
        weatherType = WeatherType.cloudy;
      } else {
        weatherType = WeatherType.cloudyNight;
      }
    }
    return weatherType;
  }

  void _onRefresh() async {
    // monitor network fetch
    await weatherController.doUpdate();
    WeatherLocation weatherLocation =
        weatherController.weatherList[weatherController.indexWeather.value];
    DateTime dateTime = DateTime.parse(weatherLocation.dateTime);
    DateTime timeNow = DateTime.now();
    var diff = timeNow.difference(dateTime);

    if (diff.inMinutes > 2) {
      if (weatherLocation.placeId == kLocationPlaceID) {
        doCurrentLocationUpdate();
      } else {
        doWeatherUpdate(weatherLocation);
      }
    } else {
      String localTime = '';
      if (diff.inMinutes >= 1) {
        localTime = '${diff.inMinutes} min ago';
      } else {
        localTime = '${diff.inSeconds} sec ago';
      }
      Get.snackbar(
        'Weather',
        'Updated $localTime',
      );
      _refreshController.refreshCompleted();
    }
  }

  void doWeatherUpdate(WeatherLocation weatherLocation) async {
    if (isConnected) {
      var result;
      //? to search the database for current Location if it exits.
      result = await dbHelper.searchForLocation(weatherLocation.placeId);
      bool? check;

      //? is Update is used for updating ,

      //?if it is true then update will occur ,

      //? if result is 1 , it means that there is a current location stored , so it will update the
      //? existing location

      if (result == 1) {
        await weatherHelper.doCurrentWeatherParseAndSave(
            lat: weatherLocation.latitude,
            long: weatherLocation.longitude,
            placeId: weatherLocation.placeId,
            isUpdate: true);
        check = false;
      }
      if (check == null) {
        Get.snackbar(
          'Info',
          "Error!",
          backgroundColor: Colors.red,
        );
        _refreshController.refreshFailed();
      }
    }
  }

  @override
  void initState() {
    AdManager.showCityBannerAd();
    checkConnectivity();
    super.initState();
  }

  @override
  void dispose() {
    AdManager.hideCityBannerAd();
    super.dispose();
  }

  checkConnectivity() {
    listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          if (mounted) {
            setState(() {
              isConnected = true;
            });
          }
          break;
        case DataConnectionStatus.disconnected:
          if (mounted) {
            setState(() {
              isConnected = false;
            });
          }
          break;
      }
    });
  }

  void doCurrentLocationUpdate() async {
    if (isConnected) {
      locationResponse = await locationHelper.getCurrentLocation();
      if (locationResponse != null) {
        var result;

        //? to search the database for current Location if it exits.
        result = await dbHelper.searchForLocation(kLocationPlaceID);
        bool? check;

        //? is Update is used for updating ,

        //?if it is true then update will occur ,

        //? if result is 1 , it means that there is a current location stored , so it will update the
        //? existing location
        if (result == 1) {
          await weatherHelper.doCurrentWeatherParseAndSave(
              lat: locationResponse?.latitude,
              long: locationResponse?.longitude,
              placeId: kLocationPlaceID,
              isUpdate: true);
          check = false;
        }
        if (check == null) {
          Get.snackbar(
            'Info',
            "Error!",
            backgroundColor: Colors.red,
          );
          _refreshController.refreshFailed();
        }
      }
      _refreshController.refreshFailed();
      return;
    }
  }

  _onPageChanged(int index) {
    weatherController.setCurrentWeatherIndex(index);
    //? here we are saving fade as false
    weatherController.saveFade(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            weatherController.setCurrentWeatherIndex(0);
            Get.to(CityScreen());
          },
          icon: Icon(
            FontAwesomeIcons.plus,
            size: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh_rounded),
              onPressed: () => _refreshController
                  .requestRefresh()
                  .then((value) => AdManager.showCityBannerAd())),
          IconButton(
            icon: Icon(FontAwesomeIcons.ellipsisV),
            onPressed: () => Get.to(
              SettingsScreen(),
            ).then((value) => AdManager.hideCityBannerAd()),
          ),
        ],
      ),
      body: Stack(
        children: [
          //? Background for Weather
          AnimatedContainer(
            duration: Duration(milliseconds: 150),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 150),
              switchOutCurve: Curves.easeInOutCubic,
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  ScaleTransition(child: child, scale: animation),
              child: GetX<WeatherController>(
                builder: (controller) {
                  WeatherLocation weatherLocation = controller
                      .weatherList[weatherController.indexWeather.value];

                  WeatherType weatherback = getWeatherBackground(
                      value: weatherLocation.condition,
                      sunrise: weatherLocation.sunRise,
                      sunset: weatherLocation.sunSet,
                      timeZone: weatherLocation.timeZone);
                  return weatherback == WeatherType.sunny
                      ? Transform.translate(
                          offset: Offset(0, 0.0),
                          child: WeatherBg(
                            height: Get.height * 100,
                            width: Get.width * 100,
                            weatherType: weatherback,
                          ),
                        )
                      : WeatherBg(
                          height: Get.height,
                          width: Get.width,
                          weatherType: weatherback,
                        );
                },
              ),
            ),
          ),

          //? Pull to refresh and its child is single weather
          SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            primary: true,
            enablePullUp: false,
            physics: BouncingScrollPhysics(),
            header: MaterialClassicHeader(),
            enablePullDown: true,
            child: GetX<WeatherController>(
              builder: (controller) {
                return PageView.builder(
                  itemCount: controller.weatherList.length,
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) => SingleWeather(
                    weatherLocation: controller.weatherList[index],
                    isUnit: controller.isTempUnitCelcius.value,
                  ),
                );
              },
            ),
          ),

          //? Slider Dot is implemented here
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.all(8),
            child: Obx(
              () => BackdropFilter(
                filter: weatherController.isFade.value
                    ? ImageFilter.blur(sigmaX: 5, sigmaY: 3)
                    : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  margin: EdgeInsets.only(
                      top: Get.statusBarHeight, left: Get.width / 2.7),
                  child: Row(
                    children: [
                      DotsIndicator(
                        dotsCount: widget.dotCount,
                        position:
                            weatherController.indexWeather.value.toDouble(),
                        decorator: DotsDecorator(
                          size: const Size.square(9.0),
                          activeSize: const Size(18.0, 9.0),
                          activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
