import 'package:apex_test_app/Models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FbFireStoreUsersController {
  final FirebaseFirestore _firebaseFireStoreUsers = FirebaseFirestore.instance;

  // CRUD

  Future<bool> create({required USER user}) async {
    return _firebaseFireStoreUsers
        .collection('Users')
        .add(user.toMap())
        .then((value) => true)
        .catchError((error) => false);
  }

  Future<bool> delete({required String path}) {
    return _firebaseFireStoreUsers
        .collection('Users')
        .doc(path)
        .delete()
        .then((value) => true)
        .catchError(((error) => false));
  }

  Stream<QuerySnapshot> read() async* {
    yield* _firebaseFireStoreUsers.collection('Users').snapshots();
  }
}
