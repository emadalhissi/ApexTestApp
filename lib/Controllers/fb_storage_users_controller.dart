import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FbStorageUsersController {

  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<void> uploadImage({required String path}) async {

    UploadTask uploadTask = _firebaseStorage.ref(DateTime.now().toString() + 'image').putFile(File(path));

  }
}