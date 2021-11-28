class WeatherLocation {
  final String city;
  final String placeId;
  final String dateTime;
  final String temperature;
  final String maxTemperature;
  final String minTemperature;
  final int locationId;
  final String feelLike;
  final String weatherType;
  final String windSpeed;
  final String windDirection;
  final String timeZone;
  final String sunSet;
  final String sunRise;
  final int humidity;
  final String weatherDescription;
  final String condition;
  final double latitude;
  final double longitude;
  final String pressure;
  final String country;

  WeatherLocation({
    required this.country,
    required this.timeZone,
    required this.placeId,
    required this.locationId,
    required this.pressure,
    required this.windDirection,
    required this.latitude,
    required this.longitude,
    required this.weatherDescription,
    required this.condition,
    required this.sunSet,
    required this.sunRise,
    required this.maxTemperature,
    required this.minTemperature,
    required this.feelLike,
    required this.city,
    required this.dateTime,
    required this.temperature,
    required this.weatherType,
    required this.windSpeed,
    required this.humidity,
  });

  Map<String, dynamic> toMap() {
    return {
      'country': country,
      'timeZone': timeZone,
      'placeId': placeId,
      'locationId': locationId,
      'pressure': pressure,
      'longitude': longitude,
      'latitude': latitude,
      'weatherDescription': weatherDescription,
      'condition': condition,
      'sunSet': sunSet,
      'sunRise': sunRise,
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
      'feelLike': feelLike,
      'city': city,
      'dateTime': dateTime,
      'temperature': temperature,
      'weatherType': weatherType,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'humidity': humidity,
    };
  }
}
