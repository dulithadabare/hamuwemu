import 'package:hamuwemu/business_logic/model/active_event_response.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

import 'abstract_view_model.dart';

class PartnerActiveEventViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();

  ActiveEventResponse? activeEvent;

  Future<void> loadEvent() async {
    setStatus(ViewModelStatus.busy);
    try {
      activeEvent = await _webApi.getPartnerEvent();
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }

  Future<bool> like() async {
    // setStatus(ViewModelStatus.busy);
    try {
      final data = await _webApi.likePartnerEvent();
      activeEvent = data[0];
      setStatus(ViewModelStatus.idle);
      return true;
      // return ApiResponse.completed('SUCCESS', data[0]);
    } on FetchDataException catch (e) {
      print(e.toString());
      // setStatus(ViewModelStatus.error);
      return false;
      // return ApiResponse.error(e.toString());
    }
  }

  Future<bool> removeLike() async {
    // setStatus(ViewModelStatus.busy);
    try {
      final data = await _webApi.removeLike();
      activeEvent = data[0];
      setStatus(ViewModelStatus.idle);
      return true;
      // return ApiResponse.completed('SUCCESS', data[0]);
    } on FetchDataException catch (e) {
      print(e.toString());
      return false;
      // return ApiResponse.error(e.toString());
    }
  }
}
