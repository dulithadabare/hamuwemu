import 'package:hamuwemu/business_logic/model/data_list_page.dart';
import 'package:hamuwemu/business_logic/model/event_history_page_item.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

import 'abstract_view_model.dart';

class EventHistoryViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();

  Future<DataListPage<EventHistoryPageItem>> loadNext( int userId, String? pageKey ) async {
    final data = await _webApi.getEventHistoryPage(userId, pageKey);

    return data[0];
  }
}
