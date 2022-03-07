import 'dart:io';

import 'package:apex_test_app/Providers/location_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

// typedef FbUploadListener = void Function({
//   String? message,
//   required TaskState taskState,
//   required bool status,
//   Reference? reference,
// });
typedef CallBackUrl = void Function({required String url,required bool status});

class FbStorageUsersController {
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<void> uploadImage({
    required File file,
    required BuildContext context,
    required CallBackUrl callBackUrl,
  }) async {
    UploadTask uploadTask = _firebaseStorage
        .ref('images/' + DateTime.now().toString() + 'image')
        .putFile(file);
    print('insidewww');
    uploadTask.snapshotEvents.listen((event) async {
      if (event.state == TaskState.running) {
        print('event.state == TaskState.running');
      } else if (event.state == TaskState.success) {
        Reference imageReference = event.ref;
        // final String imagePath = imageReference.toString();
        var url = await imageReference.getDownloadURL();
        print('event.state == TaskState.success');
        // print('String imagePath => $imagePath');
        print('URL from controller => $url');
        callBackUrl(url: url, status: true);
      } else if (event.state == TaskState.error) {
        print('event.state == TaskState.error');
      }
    });
  }
}
