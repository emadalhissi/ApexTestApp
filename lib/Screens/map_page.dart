import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:apex_test_app/Controllers/fb_firestore_users_controller.dart';
import 'package:apex_test_app/Controllers/fb_storage_users_controller.dart';
import 'package:apex_test_app/Helpers/snakbar.dart';
import 'package:apex_test_app/Models/user.dart';
import 'package:apex_test_app/Providers/location_provider.dart';
import 'package:apex_test_app/Screens/notes_screen.dart';
import 'package:apex_test_app/Screens/tracks_screen.dart';
import 'package:apex_test_app/Shared%20Preferences/shared_preferences_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as GeoLocator;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    Key? key,
    this.user,
  }) : super(key: key);

  final USER? user;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SnackBarHelper {
  // File? _myFile;
  Uint8List? _imageFile;
  String imageURL = 'imageUrl';
  bool imageStatus = false;

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
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TracksScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.track_changes),
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
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login_screen');
                  await SharedPreferencesController().logout();
                },
                icon: const Icon(Icons.logout),
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

                          final image1 =
                              await _googleMapController.takeSnapshot();
                          // uint8ListTob64(image!);
                          if (image1 == null) return;
                          await saveImage(image1);
                          await saveTrackImage();

                          Future.delayed(const Duration(seconds: 5), () async {
                            await saveTrack();
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

  Future<void> saveTrackImage() async {
    print('Entered saveTrackImage, before Cloture');
    print(Provider.of<LocationProvider>(context, listen: false).imageFile);
    await FbStorageUsersController().uploadImage(
        context: context,
        file: Provider.of<LocationProvider>(context, listen: false).imageFile,
        callBackUrl: ({required String url, required bool status}) {
          print(url);
          print('${url.toString()}');
          print('URL from map page => $url');
          print('FROM MY CALLBACK');
          setState(() {
            imageURL = url;
            imageStatus = status;
          });
          Provider.of<LocationProvider>(context, listen: false).changeImageUrl(url: url);
        });
    print('Entered saveTrackImage, after Cloture');
  }

  USER get user {
    var currentUser = FirebaseAuth.instance.currentUser;
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(now);
    String formattedTime = DateFormat.Hms().format(now);
    USER user = widget.user == null ? USER() : widget.user!;
    user.email = currentUser!.email!;
    user.date = formattedDate;
    user.time = formattedTime;
    user.startPoint =
        Provider.of<LocationProvider>(context, listen: false).startPoint;
    user.endPoint =
        Provider.of<LocationProvider>(context, listen: false).endPoint;
    user.image = Provider.of<LocationProvider>(context, listen: false).imageUrl;
    return user;
  }

  Future<void> saveTrack() async {
    print('before user: user');
    bool status = await FbFireStoreUsersController().create(user: user);
    print('after user: user');

    if (status) {
      showSnackBar(
        context,
        message: 'Added Successfully',
        error: false,
      );
    } else {
      showSnackBar(
        context,
        message: 'Add Failed',
        error: true,
      );
    }
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();

    print('converted file');
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'screenshot_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    final String filePath = result['filePath'];
    Uint8List imageInUnit8List = bytes;
    final tempDir = await getTemporaryDirectory();
    File convertedFile = await File('${tempDir.path}/image.png').create();
    convertedFile.writeAsBytesSync(imageInUnit8List);

    Provider.of<LocationProvider>(context, listen: false)
        .changeFile(file: convertedFile);
    return filePath;
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

    Provider.of<LocationProvider>(context, listen: false)
        .changeStartPoint(start: res.toString());
  }

  Future<void> _getCurrentEndLocation() async {
    GeoLocator.Position res = await GeoLocator.Geolocator.getCurrentPosition(
        desiredAccuracy: GeoLocator.LocationAccuracy.high);
    print('End Position => $res');
    setState(() {
      endPosition = res;
    });
    Provider.of<LocationProvider>(context, listen: false)
        .changeEndPoint(end: res.toString());
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
}
