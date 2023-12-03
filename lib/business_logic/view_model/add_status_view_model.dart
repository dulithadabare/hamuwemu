import 'package:hamuwemu/business_logic/model/confirmed_event.dart';
import 'package:hamuwemu/business_logic/model/current_status.dart';
import 'package:hamuwemu/business_logic/model/data_list_page.dart';
import 'package:hamuwemu/business_logic/model/event_response.dart';
import 'package:hamuwemu/business_logic/model/hw_message.dart';
import 'package:hamuwemu/business_logic/model/invite_friend_page_item.dart';
import 'package:hamuwemu/business_logic/model/response.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

import 'abstract_view_model.dart';

class AddStatusViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();
  bool _enabled = false;
  String description = '';
  Set<int> invites = {};

  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;

    notifyListeners();
  }

  void addInvite( int userId ) {
    invites.add(userId);
  }

  void removeInvite( int userId ) {
    invites.remove(userId);
  }

  Future<ApiResponse<CurrentStatus>> addStatus() async {
    setStatus(ViewModelStatus.busy);
    try {
      HwMessage message = HwMessage(creatorId: -1, content: description);
      CurrentStatus currentStatus = CurrentStatus(userId: -1, timestampUtc: 0, message: message, sendList: invites.toList(growable: false) );
      final data = await _webApi.addStatus(currentStatus);
      setStatus(ViewModelStatus.idle);
      return ApiResponse.completed('Event Cancelled', data);
    } on FetchDataException catch (e) {
      print(e);
      setStatus(ViewModelStatus.error);
      return ApiResponse.error(e.toString());
    }
  }

  Future<DataListPage<InviteFriendPageItem>> loadNext( String? pageKey ) async {
    final data = await _webApi.getFriendPage(pageKey);
    return data[0];
  }
}
