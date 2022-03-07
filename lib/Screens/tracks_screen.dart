import 'package:apex_test_app/Controllers/fb_firestore_controller.dart';
import 'package:apex_test_app/Controllers/fb_firestore_users_controller.dart';
import 'package:apex_test_app/Helpers/snakbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TracksScreen extends StatefulWidget {
  const TracksScreen({Key? key}) : super(key: key);

  @override
  _TracksScreenState createState() => _TracksScreenState();
}

class _TracksScreenState extends State<TracksScreen> with SnackBarHelper {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff222222),
        title: const Text('My Tracks'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FbFireStoreUsersController().read(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<QueryDocumentSnapshot> document = snapshot.data!.docs;
            return ListView.builder(
              itemCount: document.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0.5,
                          blurRadius: 1.5,
                          offset: const Offset(0, 0.5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date & Time:',
                                    style: TextStyle(
                                      color: Color(0xff222222),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text('${document[index].get('date')} ${document[index].get('time')}'),
                                ],
                              ),
                              IconButton(
                                onPressed: () async => await delete(path: document[index].id),
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Start Point:',
                            style: TextStyle(
                              color: Color(0xff222222),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(document[index].get('startPoint')),
                          const SizedBox(height: 15),
                          const Text(
                            'Start Point:',
                            style: TextStyle(
                              color: Color(0xff222222),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(document[index].get('endPoint')),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.track_changes,
                    color: Colors.grey,
                    size: 90,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No Tracks Yet',
                    style: TextStyle(
                      color: Color(0xff222222),
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> delete({required String path}) async {
    bool deleted = await FbFireStoreUsersController().delete(path: path);
    String message = deleted ? 'Deleted' : 'Error';
    if (deleted) {
      showSnackBar(
        context,
        message: message,
        error: !deleted,
      );
    }
  }
}
