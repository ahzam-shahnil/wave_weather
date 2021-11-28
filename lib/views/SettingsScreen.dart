import 'package:about/about.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:wave_weather/controllers/WeatherController.dart';
import 'package:wave_weather/services/HelperFunctions.dart';
import 'package:wave_weather/services/constants.dart';
import 'package:wave_weather/widgets/SettingRowTile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_icons/weather_icons.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final WeatherController weatherController = Get.find();
  @override
  void initState() {
    getSavedSelectedUnits();
    super.initState();
  }

  String? selectTemperature = kTemperatureMenuItems[0];
  String? selectWind = kWindMenuItems[0];
  String appName = 'Wave Weather';
  String version = '';

  getSavedSelectedUnits() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appName = packageInfo.appName;
      version = packageInfo.version;
    });

    await HelperFunctions.getTemperatureUnit().then((value) {
      setState(() {
        selectTemperature = value;
      });
    });
    await HelperFunctions.getWindUnit().then((value) {
      setState(() {
        selectWind = value;
      });
    });
    if (selectTemperature == null) {
      setState(() {
        selectTemperature = kTemperatureMenuItems[0];
      });
    }
    if (selectWind == null) {
      setState(() {
        selectWind = kWindMenuItems[0];
      });
    }
  }

  //? Pop up menu items for temperature
  List<PopupMenuItem<String>> temperaturePopMenuItem = kTemperatureMenuItems
      .map(
        (value) => PopupMenuItem(
          child: ListTile(
            selectedTileColor: Colors.white,
            leading: Icon(WeatherIcons.degrees),
            title: Text(value),
          ),
          value: value,
        ),
      )
      .toList();

  //? pop up menu Items for Wind
  List<PopupMenuItem<String>> windPopMenuItem = kWindMenuItems
      .map(
        (value) => PopupMenuItem(
          child: ListTile(
            selectedTileColor: Colors.white,
            title: Text(value),
          ),
          value: value,
        ),
      )
      .toList();

  _launchGithub() async {
    const url = 'https://github.com/ahzam-shahnil/ahzam_shahnil';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchPolicy() async {
    const url = 'https://waveweather.blogspot.com/2021/02/privacy-policy.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchInsta() async {
    const url = 'https://www.instagram.com/ahzam.shahnil/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData mode = Theme.of(context);
    var whichMode = mode.brightness;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          whichMode == Brightness.dark ? Colors.black : Colors.white,
      appBar: null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //? back arrow
            Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.only(left: 8, right: 3, top: 3),
                  child: Icon(
                    FontAwesomeIcons.arrowLeft,
                    size: 27,
                    color:
                        Get.isDarkMode ? Color(0xFFD8D8D8) : Color(0xFF525252),
                  ),
                ),
              ),
            ),

            //? settings heading
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 22, top: 25),
                child: AutoSizeText(
                  'Settings',
                  maxLines: 2,
                  style: GoogleFonts.lato(
                    fontSize: 30,
                    color:
                        Get.isDarkMode ? Color(0xFFD8D8D8) : Color(0xFF525252),
                  ),
                ),
              ),
            ),
            //? units Heading
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 25),
              child: AutoSizeText(
                'Units',
                maxLines: 2,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  color: Color(0xFF6E7396),
                ),
              ),
            ),

            //? this is for Temperature Unit
            SettingRowTile(
              popMenuItem: temperaturePopMenuItem,
              selected: selectTemperature!,
              title: 'Temperature Units',
              onSelected: (String value) {
                //? seleted unit is saved in Shared Preference
                HelperFunctions.saveSelectedTempUnit(value);
                weatherController.doUpdate();
                setState(() {
                  selectTemperature = value;
                });
              },
            ),

            //? this is for Wind Unit
            SettingRowTile(
              title: 'Wind Speed Units',
              popMenuItem: windPopMenuItem,
              selected: selectWind!,
              onSelected: (String value) {
                //? selected unit is saved in wind shared preference
                HelperFunctions.saveWindUnit(value);
                weatherController.doUpdate();
                setState(() {
                  selectWind = value;
                });
              },
            ),
            SizedBox(
              height: 20,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(),
            ),

            //? About Section
            Padding(
                padding: const EdgeInsets.only(left: 22, top: 30, bottom: 15),
                child: TextButton(
                  onPressed: () => showAboutPage(
                    title: Text('About Wave Weather'),
                    applicationVersion: version,
                    context: context,
                    applicationName: appName,
                    applicationLegalese:
                        'Copyright © 2021 , Wave Weather by Ahzam Shahnil',
                    applicationDescription: const Text(
                        'Weather with dynamic UI and accurate weather data.'),
                    children: <Widget>[
                      MarkdownPageListTile(
                        icon: Icon(Icons.list),
                        title: const Text('Changelog'),
                        filename: 'assets/log.md',
                      ),
                      ListTile(
                        leading: Icon(FontAwesomeIcons.instagram),
                        title: Text('@ahzam.shahnil'),
                        onTap: _launchInsta,
                      ),
                      ListTile(
                        leading: Icon(FontAwesomeIcons.github),
                        title: Text('@ahzam-shahnil'),
                        onTap: _launchGithub,
                      ),
                      ListTile(
                        leading: Icon(FontAwesomeIcons.shieldAlt),
                        title: Text('Our Privacy Policy.'),
                        onTap: _launchPolicy,
                      ),
                      LicensesPageListTile(
                        icon: Icon(Icons.favorite),
                      ),
                    ],
                    applicationIcon: const SizedBox(
                      width: 120,
                      height: 120,
                      child: Image(
                        fit: BoxFit.contain,
                        image: AssetImage('assets/icon.png'),
                      ),
                    ),
                  ),
                  child: Text('About Info'),
                )),
          ],
        ),
      ),
    );
  }
}
