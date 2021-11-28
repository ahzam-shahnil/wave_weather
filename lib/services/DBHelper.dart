import 'dart:async';
import 'package:wave_weather/models/WeatherLocation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  Database? _database;

  Future openDb() async {
    if (_database == null) {
      _database = await openDatabase(
          join((await getDatabasesPath())!, 'weather.db'),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE Weather(locationId INTEGER,city TEXT ,country TEXT, dateTime TEXT, temperature TEXT , maxTemperature TEXT, minTemperature, feelLike TEXT, weatherType TEXT, windSpeed TEXT, windDirection TEXT, sunSet TEXT, sunRise TEXT, humidity INTEGER, weatherDescription TEXT, condition TEXT, longitude REAL, latitude REAL, pressure TEXT,placeId TEXT PRIMARY KEY,timeZone TEXT)',
        );
      });
    }
  }

  Future<int> insertWeather(WeatherLocation weatherLocation) async {
    await openDb();

    return await _database!.insert('Weather', weatherLocation.toMap());
  }

  Future<List<WeatherLocation>> getWeatherLocationList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database!.query('Weather');
    return List.generate(maps.length, (i) {
      return WeatherLocation(
          country: maps[i]['country'],
          timeZone: maps[i]['timeZone'],
          placeId: maps[i]['placeId'],
          locationId: maps[i]['locationId'],
          windDirection: maps[i]['windDirection'],
          city: maps[i]['city'],
          pressure: maps[i]['pressure'],
          dateTime: maps[i]['dateTime'],
          temperature: maps[i]['temperature'],
          maxTemperature: maps[i]['maxTemperature'],
          minTemperature: maps[i]['minTemperature'],
          condition: maps[i]['condition'],
          humidity: maps[i]['humidity'],
          feelLike: maps[i]['feelLike'],
          sunRise: maps[i]['sunRise'],
          sunSet: maps[i]['sunSet'],
          weatherDescription: maps[i]['weatherDescription'],
          weatherType: maps[i]['weatherType'],
          windSpeed: maps[i]['windSpeed'],
          latitude: maps[i]['latitude'],
          longitude: maps[i]['longitude']);
    });
  }

  Future<dynamic> getCount() async {
    //database connection
    await openDb();
    var x = await _database!.rawQuery('SELECT COUNT (*) from Weather');
    var count = Sqflite.firstIntValue(x);
    return count;
  }

  Future<List<Map<String, dynamic>>> getPlaceId() async {
    //database connection
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database!.rawQuery('SELECT placeId from Weather');

    return maps;
  }

  Future<dynamic> searchForLocation(String id) async {
    //database connection

    await openDb();
    var x = await _database!
        .rawQuery('SELECT COUNT(*) from Weather WHERE placeId = ?;', [id]);
    var count = Sqflite.firstIntValue(x);
    return count;
  }

  Future<void> updateWeather(WeatherLocation weatherLocation) async {
    try {
      await openDb();
      await _database!.update('Weather', weatherLocation.toMap(),
          where: "placeId = ?", whereArgs: [weatherLocation.placeId]);
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteWeather(String placeId) async {
    try {
      await openDb();
      await _database!
          .delete('Weather', where: "placeId = ?", whereArgs: [placeId]);
    } catch (e) {
      print(e);
    }
  }
}
