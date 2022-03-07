class Note {
  late String id;
  late String title;
  late String details;

  Note();

  Note.fromMap(Map<String, dynamic> documentMap) {
    title = documentMap['title'];
    details = documentMap['details'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map['title'] = title;
    map['details'] = details;
    return map;
  }
}
