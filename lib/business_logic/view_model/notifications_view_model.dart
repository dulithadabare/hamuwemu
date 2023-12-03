import 'package:hamuwemu/business_logic/model/notification_page_item.dart';
import 'package:hamuwemu/business_logic/model/data_list_page.dart';
import 'package:hamuwemu/business_logic/view_model/infinite_list_view_model.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';
import 'package:flutter/foundation.dart';

class NotificationViewModel extends InfiniteListViewModel<NotificationPageItem> {
  final WebApi _webApi = WebApi();

  @override
  Future<DataListPage<NotificationPageItem>> loadNext(String? pageKey) async {
    final data = await _webApi.getAppNotifications(pageKey);

    return data[0];
  }

}
