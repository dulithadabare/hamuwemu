class AddFriendReq {
  final int friendId;
  final String? displayName;

  AddFriendReq({
    required this.friendId,
    required this.displayName,
  });

  factory AddFriendReq.fromJson(Map<String, dynamic> json) {
    return AddFriendReq(
      friendId: json['friendId'],
      displayName: json['displayName'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'friendId' : this.friendId,
      'displayName' : this.displayName,
    };
  }

  static AddFriendReq fromJsonModel(Map<String, dynamic> json) => AddFriendReq.fromJson(json);
}