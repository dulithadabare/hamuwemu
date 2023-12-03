import 'package:hamuwemu/business_logic/model/active_event.dart';
import 'package:hamuwemu/business_logic/model/active_event_response.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

import 'abstract_view_model.dart';

class ActiveEventViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();

  ActiveEventResponse? activeEvent;

  Future<void> loadEvent() async {
    setStatus(ViewModelStatus.busy);
    try {
      activeEvent = await _webApi.getActiveEvent();
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }

  Future<void> joinEvent( int userId, String? description ) async {
    setStatus(ViewModelStatus.busy);
    try {
      ActiveEvent event = ActiveEvent(userId: userId, description: description, timestampUtc: 0);
      final data = await _webApi.joinEvent(event);
      activeEvent = data[0];
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }

  Future<void> leaveEvent() async {
    setStatus(ViewModelStatus.busy);
    try {
      final data = await _webApi.leaveEvent();
      activeEvent = data[0];
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }
}
