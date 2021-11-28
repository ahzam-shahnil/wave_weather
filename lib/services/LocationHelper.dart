import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationHelper {
  // bool isOk = false;

  void showOpenSettingsDialog() {
    Get.defaultDialog(
      title: 'Location...',
      titleStyle: TextStyle(
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
      middleTextStyle: TextStyle(color: Colors.black),
      middleText: 'Please allow location permission.',
      actions: [
        Text(
          'Location access is required for getting current weather.',
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
      confirm: ElevatedButton(
          onPressed: () async {
            await Geolocator.openAppSettings();
            Get.back();
          },
          child: Text('Open')),
      cancel:
          ElevatedButton(onPressed: () => Get.back(), child: Text('Cancel')),
    );
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        showOpenSettingsDialog();
        // return Future.error('Location permissions are denied');
      }

      if (permission == LocationPermission.denied) {
        // // Permissions are denied, next time you could try
        // // requesting permissions again (this is also where
        // // Android's shouldShowRequestPermissionRationale
        // // returned true. According to Android guidelines
        // // your App should show an explanatory UI now.
        // return Future.error('Location permissions are denied');
      }
    }
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      openLocationSettingsDialog();
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return await Geolocator.getCurrentPosition().timeout(Duration(seconds: 20));
  }

  void openLocationSettingsDialog() {
    Get.defaultDialog(
      title: 'Location',
      titleStyle: TextStyle(
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
      middleTextStyle: TextStyle(color: Colors.black),
      middleText: 'Please make sure you enable location and try again',
      actions: [
        Text(
          'To get current weather needs location service to be enabled',
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
      confirm: ElevatedButton(
          onPressed: () async {
            await Geolocator.openLocationSettings();
            Get.back();
          },
          child: Text('Open')),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: Text('Cancel'),
      ),
    );
  }
}
