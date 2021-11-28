import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:wave_weather/models/UserSessionId.dart';
import 'package:wave_weather/services/AdManager.dart';
import 'package:wave_weather/services/DBHelper.dart';
import 'package:wave_weather/controllers/PlaceController.dart';
import 'package:wave_weather/services/NetworkHelper.dart';
import 'package:wave_weather/services/weatherHelper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wave_weather/services/constants.dart';
import 'package:wave_weather/models/Place.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

GoogleMapsPlaces _googleMaps = GoogleMapsPlaces(apiKey: kPlacesApiKey);

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isLoading = false;
  String _heading = "Suggestions";

  final TextEditingController _searchController = TextEditingController();
  final PlaceController placeController = Get.put(PlaceController());
  //* for listening to the Connectivity
  var listener;
  bool isFocused = true;
  bool isConnected = true;

  WeatherHelper weatherHelper = WeatherHelper();
  DBHelper dbHelper = DBHelper();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    _heading = "Suggestions";
    placeController.doUpdate();
    checkConnectivity();
    super.initState();
  }

  @override
  void dispose() {
    resetSearch();
    _searchController.dispose();
    _displayResults.clear();
    listener.cancel();
    _searchFocus.dispose();
    super.dispose();
  }

  resetSearch() {
    _searchFocus.unfocus();
    _searchController.clear();
  }

  checkConnectivity() {
    listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          setState(() {
            isConnected = true;
            isLoading = false;
            _displayResults.clear();
          });
          break;
        case DataConnectionStatus.disconnected:
          setState(() {
            isConnected = false;
            isLoading = false;
            _displayResults.clear();
          });
          break;
      }
    });
  }

  List<Place> _displayResults = [];
  final List<Place> _suggestedlist = [
    Place(cityName: "London, UK", placeId: "ChIJdd4hrwug2EcRmSrV3Vo6llI"),
    Place(
        cityName: "Mumbai, Maharastra, India",
        placeId: "ChIJwe1EZjDG5zsRaYxkjY_tpF0"),
    Place(cityName: "Lahore, Pakistan", placeId: "ChIJ2QeB5YMEGTkRYiR-zGy-OsI"),
    Place(
        cityName: "Islamabad, Pakistan",
        placeId: "ChIJL3KReNC_3zgRtgLbO1xRWWA"),
  ];

  getSearchResult() {
    _searchFocus.unfocus();
    if (_searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      getSearchedLocation(_searchController.text);
    } else {
      setState(() {
        isLoading = false;
        _heading = "Suggestions";
        _displayResults.clear();
        placeController.updatePlaces(_suggestedlist);
      });
    }
  }

  void getSearchedLocation(String input) async {
    if (input.trim().isEmpty) {
      setState(() {
        _heading = "Suggestions";
        placeController.updatePlaces(_suggestedlist);
        _displayResults.clear();
        isLoading = false;
      });
      return;
    }
    if (_displayResults.isNotEmpty) {
      _displayResults.clear();
    }

    //getting Base Url from constants file
    String baseUrl = kPlaceApiBaseURL;

    // type decides what to appear in places api response .regions gives back only the cities or country
    String type = '(cities)';

    //session token is used to group the query and selection phases of a user autocomplete search into a discrete session for billing purposes
    String sessionToken = Uuid().generateV4();
    String request =
        '$baseUrl?input=$input&key=$kPlacesApiKey&type=$type&sessiontoken=$sessionToken';

    NetworkHelper networkHelper = NetworkHelper(request);

    final prediction = await networkHelper.getData();

    final predictions = prediction['predictions'];

    for (var i = 0; i < predictions.length; i++) {
      _displayResults.add(
        Place(
          cityName: predictions[i]['description'],
          placeId: predictions[i]['place_id'],
        ),
      );
    }

    if (_searchController.text.isNotEmpty) {
      setState(() {
        _heading = "Results";
        placeController.updatePlaces(_displayResults);
      });
    } else {
      setState(() {
        _heading = "Suggestions";
        placeController.updatePlaces(_suggestedlist);
        _displayResults.clear();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData mode = Theme.of(context);
    var whichMode = mode.brightness;
    return Scaffold(
      backgroundColor:
          whichMode == Brightness.dark ? Colors.black : Colors.white,
      appBar: null,
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        // dismissible: true,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLoading = false;
                      });
                      resetSearch();
                      Get.back();
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 6, right: 3),
                      child: Icon(
                        FontAwesomeIcons.arrowLeft,
                        size: 20,
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 20)),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode
                            ? Color(0xff424242)
                            : Color(0xFFEBE9E9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        autofocus: isFocused,
                        controller: _searchController,
                        focusNode: _searchFocus,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(FontAwesomeIcons.searchLocation),
                      onPressed: () {
                        if (isConnected) {
                          getSearchResult();
                        }
                      }),
                ],
              ),
              isConnected
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: AutoSizeText(
                        _heading,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(
                      height: 50,
                    ),
              Divider(),
              isConnected
                  ? Expanded(
                      child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: placeController.placesList.length,
                      itemBuilder: (context, index) =>
                          buildPlaceCard(context, index, placeController),
                    ))
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AutoSizeText(
                              'Couldn\'t connect to the network',
                              maxLines: 2,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.wifi_off_outlined,
                              color: Colors.red,
                              size: 35,
                            ),
                          ],
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: Get.height * 0.01),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: Get.isDarkMode
                                ? Color(0xff424242)
                                : Colors.black,
                            child: TextButton(
                              style: ButtonStyle(
                                enableFeedback: true,
                              ),
                              child: AutoSizeText(
                                'Try again',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                checkConnectivity();
                              },
                            ),
                          ),
                        )
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlaceCard(BuildContext context, int index, controller) {
    checkPlaceId() {
      bool equal = false;
      placeController.refreshPLaceId();
      if (controller.placeMapId == null) {
        return equal;
      }
      for (var i = 0; i < controller.placeMapId.length; i++) {
        if (controller.placesList[index].placeId ==
            controller.placeMapId[i]['placeId']) {
          equal = true;
        }
      }
      return equal;
    }

    return Container(
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: AutoSizeText(
                                controller.placesList[index].cityName,
                                maxLines: 2,
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                checkPlaceId()
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Added',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          FontAwesomeIcons.plusCircle,
                          color:
                              Get.isDarkMode ? Colors.white : Color(0xff4A4E69),
                        ),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          PlacesDetailsResponse detail =
                              await _googleMaps.getDetailsByPlaceId(
                                  controller.placesList[index].placeId);
                          final lat = detail.result.geometry.location.lat;
                          final lng = detail.result.geometry.location.lng;

                          await weatherHelper.doWeatherParseAndSave(
                            city: controller.placesList[index].cityName,
                            placeId: controller.placesList[index].placeId,
                            lat: lat,
                            long: lng,
                            isUpdate: false,
                          );
                          if (_searchController.text.trim().isEmpty) {
                            controller.updatePlaces(_suggestedlist);
                          } else {
                            controller.updatePlaces(_displayResults);
                          }
                          setState(() {
                            isLoading = false;
                          });
                          AdManager.showInterstitaialAd();
                        },
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
