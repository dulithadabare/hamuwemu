class Location {
  final double latitude;
  final double longitude;
  final String text;
  final DateTime date;

  Location(this.text, this.date, this.latitude, this.longitude);

  Location.fromJson(Map<dynamic, dynamic> json)
      : date = DateTime.parse(json['date'] as String),
        latitude = json['latitude'] as double,
        longitude = json['longitude'] as double,
        text = json['text'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'date': date.toString(),
    'text': text,
    'latitude': latitude,
    'longitude': longitude,
  };

}
