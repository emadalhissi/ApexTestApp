import 'package:apex_test_app/Models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FbFireStoreController {
  final FirebaseFirestore _firebaseFireStore = FirebaseFirestore.instance;

  // CRUD

  Future<bool> create({required Note note}) async {
    return _firebaseFireStore
        .collection('Notes')
        .add(note.toMap())
        .then((value) => true)
        .catchError((error) => false);
  }

  Future<bool> delete({required String path}) {
    return _firebaseFireStore
        .collection('Notes')
        .doc(path)
        .delete()
        .then((value) => true)
        .catchError((error) => false);
  }

  Future<bool> update({required Note note}) {
    return _firebaseFireStore
        .collection('Notes')
        .doc(note.id)
        .update(note.toMap())
        .then((value) => true)
        .catchError((error) => false);
  }

  Stream<QuerySnapshot> read() async* {
    yield* _firebaseFireStore.collection('Notes').snapshots();
  }
}
