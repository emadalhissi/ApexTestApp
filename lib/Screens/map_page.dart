import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  List<LatLng> latLng = <LatLng>[];

  PolylinePoints polylinePoints = PolylinePoints();

  bool started = false;
  late Position startPosition;
  late Position endPosition;

  late LatLng SOURCE_LOCATION =
      LatLng(startPosition.latitude, startPosition.longitude);
  late LatLng DEST_LOCATION =
      LatLng(endPosition.latitude, endPosition.longitude);
  CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(31.524419, 34.443559),
    zoom: 16,
  );

  late GoogleMapController _googleMapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xff222222),
        title: const Text('Google Map'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _cameraPosition,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _googleMapController = controller;
              });
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            polylines: _polyline,
            markers: _markers,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (started == false) {
                      await askPermission();
                      emptyLatLngList();
                      _getCurrentStartLocation();
                    } else if (started == true) {
                      await _getCurrentEndLocation();
                      await setPolyLines();
                    }
                    setState(() {
                      started == false ? started = true : started = false;
                    });
                  },
                  child: started == false
                      ? const Text('Start Tracking')
                      : const Text('Stop Tracking'),
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xff222222),
                    minimumSize: const Size(200, 50),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> askPermission() async {
    var request = await Permission.location.request();
    if (request.isGranted) {
      print('Granted');
    } else if (request.isDenied) {
      print('Denied');
    }
  }

  void _getCurrentStartLocation() async {
    Position res = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('Start Position => $res');
    setState(() {
      startPosition = res;
    });
  }

  Future<void> _getCurrentEndLocation() async {
    Position res = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('End Position => $res');
    setState(() {
      endPosition = res;
    });
  }

  Future<void> setPolyLines() async {
    setState(() {
      latLng.add(LatLng(startPosition.latitude, startPosition.longitude));
      latLng.add(LatLng(endPosition.latitude, endPosition.longitude));
    });
    print('setPolyLines---');
    _polyline.add(Polyline(
      polylineId: PolylineId('PolylineId_1'),
      visible: true,
      //latlng is List<LatLng>
      points: latLng,
      color: Colors.blue,
    ));
    // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    //   'AIzaSyC_uh8btX_71OyrC9lyelItGOqM6syGGOw',
    //   PointLatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
    //   PointLatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude),
    // );
  }

  void emptyLatLngList() {
    setState(() {
      latLng.clear();
    });
  }
}
