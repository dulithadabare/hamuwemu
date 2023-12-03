import 'package:hamuwemu/business_logic/model/data_list_page.dart';
import 'package:hamuwemu/business_logic/model/event_history_page_item.dart';
import 'package:hamuwemu/business_logic/model/status_history_page_item.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

import 'abstract_view_model.dart';

class HistoryViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();

  Future<DataListPage<StatusHistoryPageItem>> loadNext( int userId, String? pageKey ) async {
    final data = await _webApi.getHistoryPage(userId, pageKey);

    return data[0];
  }
}
