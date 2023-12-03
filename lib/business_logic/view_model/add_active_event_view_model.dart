import 'package:hamuwemu/business_logic/model/active_event.dart';
import 'package:hamuwemu/business_logic/model/event.dart';
import 'package:hamuwemu/business_logic/model/event_response.dart';
import 'package:hamuwemu/business_logic/model/response.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

import 'abstract_view_model.dart';

class AddActiveEventViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();
  String description = '';
  bool _enabled = false;

  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;

    notifyListeners();
  }

  Future<ApiResponse<EventResponse>> addActiveEvent(int userId) async {
    setStatus(ViewModelStatus.busy);
    ActiveEvent event = ActiveEvent(userId: userId, description: description, timestampUtc: 0);
    try {
      final data = await _webApi.joinEvent(event);
      setStatus(ViewModelStatus.idle);
      return ApiResponse.completed('Loaded Event', data[0]);
    } on FetchDataException catch (e) {
      print(e);
      setStatus(ViewModelStatus.error);
      return ApiResponse.error(e.toString());
    }
  }
}
