class PhoneContact {
  String displayName;
  String phoneNumber;

  PhoneContact({
    required this.displayName,
    required this.phoneNumber,
  });

  factory PhoneContact.fromJson(Map<String, dynamic> json) {
    return PhoneContact(
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': this.displayName,
      'phoneNumber': this.phoneNumber,
    };
  }

  static PhoneContact fromJsonModel(Map<String, dynamic> json) => PhoneContact.fromJson(json);
}
