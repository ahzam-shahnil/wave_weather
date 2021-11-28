import 'dart:async';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wave_weather/controllers/PlaceController.dart';
import 'package:wave_weather/controllers/WeatherController.dart';
import 'package:wave_weather/services/AdManager.dart';
import 'package:wave_weather/services/DBHelper.dart';
import 'package:wave_weather/services/LocationHelper.dart';
import 'package:wave_weather/services/weatherHelper.dart';
import 'package:wave_weather/services/constants.dart';
import 'package:wave_weather/views/SearchScreen.dart';
import 'package:wave_weather/views/HomeScreen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class CityScreen extends StatefulWidget {
  @override
  _CityScreenState createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  final WeatherController weatherController = Get.put(WeatherController());
  final PlaceController placeController = Get.put(PlaceController());
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();

  final WeatherHelper weatherHelper = WeatherHelper();
  final DBHelper dbHelper = DBHelper();
  final LocationHelper locationHelper = LocationHelper();
  SlidableController slidableController = SlidableController();
  Position? locationResponse;

  var listener;

  bool isFocused = true;
  bool isConnected = true;

  @override
  void initState() {
    checkConnectivity();
    super.initState();
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

  void _doSomethingOnLocate() async {
    if (isConnected) {
      locationResponse = await locationHelper.getCurrentLocation();

      if (locationResponse != null) {
        var result;

        //? to search the database for current Location if it exits.
        result = await dbHelper.searchForLocation(kLocationPlaceID);

        //? is Update is a bool variable if it is true then updation will occur
        //? if it is false , it means that insertion will occur.

        bool? check;
        //? if result is 0, it means there is no current location , insertion will occur at database

        if (result == 0) {
          await weatherHelper.doCurrentWeatherParseAndSave(
              lat: locationResponse?.latitude,
              long: locationResponse?.longitude,
              isUpdate: false,
              placeId: kLocationPlaceID);
          check = true;
        }
        //? if result is 1 , it means that there is a current location stored , so it will update the
        //? existing location
        else if (result == 1) {
          await weatherHelper.doCurrentWeatherParseAndSave(
              lat: locationResponse?.latitude,
              long: locationResponse?.longitude,
              isUpdate: true,
              placeId: kLocationPlaceID);
          check = false;
        }
        if (check == null) {
          Get.snackbar(
            'Info',
            "Error!",
          );
          _btnController.stop();
        }
      }
      _btnController.reset();
    }
    //? To reset the button to 2 seconds of completion of its task
    Timer(Duration(seconds: 1), () {
      _btnController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData mode = Theme.of(context);
    var whichMode = mode.brightness;
    bool back;

    return WillPopScope(
      onWillPop: () async {
        setState(() {});
        if (weatherController.count.value != 0) {
          HomeScreen.toRefresh = false;
          Get.offAll(HomeScreen(
            dotCount: await checkWeatherForEmpty(),
          ));
          back = true;
          return back;
        } else {
          back = false;
          return back;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor:
            whichMode == Brightness.dark ? Colors.black : Colors.white,
        appBar: null,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      if (weatherController.count.value != 0) {
                        //? to make the dot index back to the zero index
                        weatherController.indexWeather.value = 0;
                        HomeScreen.toRefresh = false;
                        Get.offAll(HomeScreen(
                          dotCount: await checkWeatherForEmpty(),
                        ));
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 6, right: 3),
                      child: Icon(
                        FontAwesomeIcons.arrowLeft,
                        size: 27,
                        color: Get.isDarkMode
                            ? Color(0xFFD8D8D8)
                            : Color(0xFF525252),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 22, top: 30),
                    child: AutoSizeText(
                      'Add city',
                      maxLines: 2,
                      style: GoogleFonts.lato(
                        fontSize: 30,
                        color: Get.isDarkMode
                            ? Color(0xFFD8D8D8)
                            : Color(0xFF525252),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(SearchScreen());
                        },
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? Color(0xff424242)
                                : Color(0xFFDFDFDF),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5)),
                              Icon(
                                Icons.search,
                              ),
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5)),
                              AutoSizeText(
                                "Search",
                                style: GoogleFonts.lato(
                                    color: Get.isDarkMode
                                        ? Color(0xFFD8D8D8)
                                        : Color(0xFF353535)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Text('or '),

                    //?Locate Button implemetation
                    SizedBox(
                      width: Get.width * 0.4,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: RoundedLoadingButton(
                          successColor: Colors.green,
                          color: Get.isDarkMode
                              ? Color(0xff3167A6)
                              : Color(0xFF936DF3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: AutoSizeText(
                                    'Locate',
                                    maxLines: 2,
                                    style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          controller: _btnController,
                          onPressed: _doSomethingOnLocate,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 22, top: 30, bottom: 15),
                  child: AutoSizeText(
                    'Manage cities',
                    maxLines: 2,
                    style: GoogleFonts.lato(
                      fontSize: 30,
                      color: Get.isDarkMode
                          ? Color(0xFFD8D8D8)
                          : Color(0xFF525252),
                    ),
                  ),
                ),
                Obx(() => ListView.builder(
                      shrinkWrap: true,
                      itemCount: weatherController.weatherList.length,
                      itemBuilder: (context, index) =>
                          showAddedCities(context, index, weatherController),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showAddedCities(
      BuildContext context, int index, WeatherController controller) {
    return Slidable(
      actionPane: SlidableStrechActionPane(),
      direction: Axis.horizontal,
      actionExtentRatio: 0.20,
      fastThreshold: 1,
      controller: slidableController,
      movementDuration: Duration(milliseconds: 300),
      closeOnScroll: true,
      secondaryActions: <Widget>[
        CircleAvatar(
          backgroundColor: Color(0xff3167A6),
          radius: 30,
          child: IconButton(
            icon: Icon(
              FontAwesomeIcons.trashAlt,
              color: Colors.white,
            ),
            onPressed: () async {
              await dbHelper
                  .deleteWeather(controller.weatherList[index].placeId)
                  .then((value) {
                controller.doUpdate();
                placeController.doUpdate();
              });
            },
          ),
        ),
      ],
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Get.isDarkMode ? Color(0xff3167A6) : Color(0xffDEE2FF),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: AutoSizeText(
                                  controller.weatherList[index].city,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: AutoSizeText(
                                    '${controller.weatherList[index].weatherDescription.capitalize}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        controller.weatherList[index].placeId ==
                                kLocationPlaceID
                            ? AutoSizeText(
                                'Current Location',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              )
                            : Container(
                                height: 0,
                                width: 0,
                              )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
