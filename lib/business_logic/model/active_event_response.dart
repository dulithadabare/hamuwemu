import 'package:hamuwemu/business_logic/model/active_event.dart';

class ActiveEventResponse {
  final ActiveEvent event;
  bool liked;

  ActiveEventResponse({
    required this.event,
    required this.liked,
  });

  factory ActiveEventResponse.fromJson(Map<String, dynamic> json) {
    return ActiveEventResponse(
      liked: json['liked'],
      event: ActiveEvent.fromJson(json['event']),
    );
  }

  static ActiveEventResponse fromJsonModel(Map<String, dynamic> json) => ActiveEventResponse.fromJson(json);

}