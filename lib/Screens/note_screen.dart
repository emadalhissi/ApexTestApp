import 'package:apex_test_app/Controllers/fb_firestore_controller.dart';
import 'package:apex_test_app/Helpers/snakbar.dart';
import 'package:apex_test_app/Models/note.dart';
import 'package:flutter/material.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({
    Key? key,
    this.title = 'Create',
    this.note,
  }) : super(key: key);

  final String title;
  final Note? note;

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> with SnackBarHelper {
  late TextEditingController _titleEditingController;
  late TextEditingController _detailsEditingController;

  @override
  void initState() {
    super.initState();
    _titleEditingController = TextEditingController(text: widget.note?.title ?? '');
    _detailsEditingController = TextEditingController(text: widget.note?.title ?? '');
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _detailsEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          TextField(
            controller: _titleEditingController,
            decoration: const InputDecoration(
              hintText: 'Title',
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _detailsEditingController,
            decoration: const InputDecoration(
              hintText: 'Details',
              prefixIcon: Icon(Icons.details),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () async => await performProcess(),
            child: const Text('SAVE'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 50),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> performProcess() async {
    if (checkData()) {
      await process();
    }
  }

  bool checkData() {
    if (_titleEditingController.text.isNotEmpty &&
        _detailsEditingController.text.isNotEmpty) {
      return true;
    }
    showSnackBar(
      context,
      message: 'Enter data',
      error: true,
    );
    return false;
  }

  Future<void> process() async {
    bool status = widget.note == null
        ? await FbFireStoreController().create(note: note)
        : await FbFireStoreController().update(note: note);

    if (status) {
      if (widget.note == null) {
        Navigator.pop(context);
      } else {
        clear();
      }
    }
    showSnackBar(
      context,
      message: status ? 'Success' : 'Failed',
      error: !status,
    );
  }

  Note get note {
    Note note = widget.note == null ? Note() : widget.note!;
    note.title = _titleEditingController.text;
    note.details = _detailsEditingController.text;
    return note;
  }

  void clear() {
    _titleEditingController.text = '';
    _detailsEditingController.text = '';
  }
}
