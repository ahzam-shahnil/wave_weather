import 'package:wave_weather/models/Place.dart';
import 'package:get/state_manager.dart';
import '../services/DBHelper.dart';

class PlaceController extends GetxController {
  var placeMapId = <Map<String, dynamic>>[].obs;
  var placesList = <Place>[].obs;
  DBHelper dbHelper = DBHelper();
  List<Place> _suggestedlist = [
    Place(cityName: "London, UK", placeId: "ChIJdd4hrwug2EcRmSrV3Vo6llI"),
    Place(
        cityName: "Mumbai, Maharastra, India",
        placeId: "ChIJwe1EZjDG5zsRaYxkjY_tpF0"),
    Place(cityName: "Lahore, Pakistan", placeId: "ChIJ2QeB5YMEGTkRYiR-zGy-OsI"),
    Place(
        cityName: "Islamabad, Pakistan",
        placeId: "ChIJL3KReNC_3zgRtgLbO1xRWWA"),
  ];

  @override
  void onInit() {
    super.onInit();
    doUpdate();
  }

  doUpdate() async {
    await refreshPLaceId();
    updatePlaces(_suggestedlist);
  }

  updatePlaces(List<Place> input) {
    placesList.clear();
    placesList.assignAll(input);
  }

  refreshPLaceId() async {
    await dbHelper.getPlaceId().then((value) {
      placeMapId.assignAll(value);
    });
  }
}
