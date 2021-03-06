class USER {
  late String id;
  late String email;
  late String date;
  late String time;
  late String startPoint;
  late String endPoint;
  late String image;

  USER();

  USER.fromMap(Map<String, dynamic> documentMap) {
    email = documentMap['email'];
    date = documentMap['date'];
    time = documentMap['time'];
    startPoint = documentMap['startPoint'];
    endPoint = documentMap['endPoint'];
    image = documentMap['image'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map['email'] = email;
    map['date'] = date;
    map['time'] = time;
    map['startPoint'] = startPoint;
    map['endPoint'] = endPoint;
    map['image'] = image;
    return map;
  }
}
