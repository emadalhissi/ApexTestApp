import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider extends ChangeNotifier {
  // String lang = SharedPreferencesController().checkLanguage;
  //
  // void changeLang(String language) {
  //   // lang = language;
  //   SharedPreferencesController().setLanguage(language: language);
  //   notifyListeners();
  // }

  late double myLatLocation = 0;
  late double myLngLocation = 0;

  late String startPoint;
  late String endPoint;

  late String imageUrl;

  late File imageFile;

  late CameraPosition myCameraPosition = CameraPosition(
    target: LatLng(myLatLocation, myLngLocation),
    zoom: 18,
  );

  void changeLocation({required double Lat, required double Lng}) {
    myLatLocation = Lat;
    myLngLocation = Lng;
    notifyListeners();
  }

  void changeCameraPosition({required CameraPosition cameraPosition}) {
    myCameraPosition = cameraPosition;
    notifyListeners();
  }

  void changeStartPoint({required String start}) {
    startPoint = start;
    notifyListeners();
  }

  void changeEndPoint({required String end}) {
    endPoint = end;
    notifyListeners();
  }

  Future<void> changeImageUrl({required String url}) async {
    imageUrl = url;
    notifyListeners();
    
  }

  void changeFile({required File file}) {
    imageFile = file;
    notifyListeners();
  }
}
