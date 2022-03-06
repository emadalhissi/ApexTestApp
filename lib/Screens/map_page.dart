import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:apex_test_app/Providers/lang_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as GeoLocator;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  DocumentReference user =
      FirebaseFirestore.instance.collection('test').doc('9D6COaDRianpqxkkXo2R');

  Future<void> addUser() {
    // Call the user's CollectionReference to add a new user
    return user.update({
          'full_name': 'Emad Alhissi',
          'company': 'Apex for IT Solutions',
          'age': '23',
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  // File? _myFile;
  Uint8List? _imageFile;

  final screenshotController = ScreenshotController();

  static GlobalKey previewContainer = GlobalKey();

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  List<LatLng> latLng = <LatLng>[];

  PolylinePoints polylinePoints = PolylinePoints();

  bool started = false;
  late GeoLocator.Position startPosition;
  late GeoLocator.Position endPosition;

  late GoogleMapController _googleMapController;

  late CameraPosition _cameraPosition;

  @override
  void initState() {
    super.initState();
    askPermission();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: previewContainer,
      child: Screenshot(
        controller: screenshotController,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: IconButton(
              onPressed: addUser,
              icon: const Icon(Icons.add),
            ),
            backgroundColor: const Color(0xff222222),
            title: const Text('Google Map'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  emptyLatLngList();
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition:
                    Provider.of<LocationProvider>(context).myCameraPosition,
                onMapCreated: (GoogleMapController controller) async {
                  setState(() {
                    _googleMapController = controller;
                  });
                  await _getLocation();
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
                          await _getCurrentStartLocation();
                        } else if (started == true) {
                          await _getCurrentEndLocation();
                          await setPolyLines();
                          // takeScreenShot();
                          // await _captureScreen();
                          // final image = await screenshotController.capture(delay: const Duration(seconds: 1));
                          Future.delayed(const Duration(seconds: 3), () async {
                            final image1 =
                                await _googleMapController.takeSnapshot();
                            // uint8ListTob64(image!);
                            if (image1 == null) return;
                            saveImage(image1);
                          });
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
        ),
      ),
    );
  }

  // String uint8ListTob64(Uint8List uint8list) {
  //   String base64String = base64Encode(uint8list);
  //   String header = "data:image/png;base64,";
  //   return header + base64String;
  // }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();

    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'screenshot_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    return result['filePath'];
  }

  Future<void> _getLocation() async {
    var location = Location();
    try {
      var currentLocation = await location.getLocation();
      Provider.of<LocationProvider>(context, listen: false).changeLocation(
        Lat: currentLocation.latitude!,
        Lng: currentLocation.longitude!,
      );
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        ),
        zoom: 18,
      );
      Provider.of<LocationProvider>(context, listen: false)
          .changeCameraPosition(cameraPosition: cameraPosition);
    } on Exception {
      // currentLocation = null;
    }
    Future.delayed(const Duration(seconds: 2), () {
      moveCamera();
    });
  }

  Future<void> moveCamera() async {
    _googleMapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            Provider.of<LocationProvider>(context, listen: false).myLatLocation,
            Provider.of<LocationProvider>(context, listen: false).myLngLocation,
          ),
          zoom: 18,
        ),
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

  Future<void> _getCurrentStartLocation() async {
    GeoLocator.Position res = await GeoLocator.Geolocator.getCurrentPosition(
        desiredAccuracy: GeoLocator.LocationAccuracy.high);
    print('Start Position => $res');
    setState(() {
      _cameraPosition = CameraPosition(
        target: LatLng(res.latitude, res.longitude),
        zoom: 16,
      );
      startPosition = res;
    });
  }

  Future<void> _getCurrentEndLocation() async {
    GeoLocator.Position res = await GeoLocator.Geolocator.getCurrentPosition(
        desiredAccuracy: GeoLocator.LocationAccuracy.high);
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
      polylineId: const PolylineId('PolylineId_1'),
      visible: true,
      points: latLng,
      color: Colors.blue,
    ));
  }

  void emptyLatLngList() {
    setState(() {
      latLng.clear();
    });
  }

// void takeScreenShot() async {
//   print('===takeScreenShot===');
//   await [Permission.storage].request();
//
//   final time = DateTime.now()
//       .toIso8601String()
//       .replaceAll('.', '-')
//       .replaceAll(':', '-');
//   final name = 'screenshot_$time';
//
//   RenderRepaintBoundary boundary = previewContainer.currentContext!
//       .findRenderObject() as RenderRepaintBoundary;
//   ui.Image image = await boundary.toImage();
//   final directory = (await getApplicationDocumentsDirectory()).path;
//   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//   Uint8List pngBytes = byteData!.buffer.asUint8List();
//   print(pngBytes);
//   File imgFile = File('$directory/$name.png');
//   final file = await imgFile.writeAsBytes(pngBytes);
//   print(file);
// }
//
// Future<void> _captureScreen() async {
//   print('_captureScreen');
//   await [Permission.storage].request();
//
//   final time = DateTime.now()
//       .toIso8601String()
//       .replaceAll('.', '-')
//       .replaceAll(':', '-');
//   final name = 'screenshot_$time';
//   List<String> imagePaths = [];
//   final RenderBox box = context.findRenderObject() as RenderBox;
//   return Future.delayed(const Duration(milliseconds: 20), () async {
//     RenderRepaintBoundary? boundary = previewContainer.currentContext!
//         .findRenderObject() as RenderRepaintBoundary?;
//     ui.Image image = await boundary!.toImage();
//     final directory = (await getApplicationDocumentsDirectory()).path;
//     ByteData? byteData =
//         await image.toByteData(format: ui.ImageByteFormat.png);
//     Uint8List pngBytes = byteData!.buffer.asUint8List();
//     File imgFile = File('$directory/$name.png');
//     print(imgFile);
//     imgFile.writeAsBytes(pngBytes);
//     setState(() {
//       _myFile = imgFile;
//     });
//     // imagePaths.add(imgFile.path);
//     // imgFile.writeAsBytes(pngBytes).then((value) async {
//     //   // await Share.shareFiles(imagePaths,
//     //   //     subject: 'Share',
//     //   //     text: 'Check this Out!',
//     //   //     sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
//     // }).catchError((onError) {
//     //   print(onError);
//     // });
//   });
// }
}
