import 'package:apex_test_app/Controllers/fb_firestore_controller.dart';
import 'package:apex_test_app/Helpers/snakbar.dart';
import 'package:apex_test_app/Models/note.dart';
import 'package:apex_test_app/Screens/note_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SnackBarHelper {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoteScreen(),
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FbFireStoreController().read(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.note),
                  title: Text(documents[index].get('title')),
                  subtitle: Text(documents[index].get('details')),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async =>
                        await delete(path: documents[index].id),
                    color: Colors.red,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteScreen(
                          title: 'Update',
                          note: mapNote(documents[index]),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.warning,
                    size: 85,
                  ),
                  Text('NO DATA'),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> delete({required String path}) async {
    bool deleted = await FbFireStoreController().delete(path: path);
    String message = deleted ? 'Deleted' : 'Error';
    if (deleted) {
      showSnackBar(
        context,
        message: message,
        error: !deleted,
      );
    }
  }

  Note mapNote(QueryDocumentSnapshot documentSnapshot) {
    Note note = Note();
    note.id = documentSnapshot.id;
    note.title = documentSnapshot.get('title');
    note.details = documentSnapshot.get('details');
    return note;
  }
}
