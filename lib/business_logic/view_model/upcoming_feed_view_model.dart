import 'package:hamuwemu/business_logic/model/data_list_page.dart';
import 'package:hamuwemu/business_logic/model/upcoming_page_item.dart';
import 'package:hamuwemu/business_logic/view_model/infinite_list_view_model.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

class UpcomingFeedViewModel extends InfiniteListViewModel<UpcomingPageItem> {
  final WebApi _webApi = WebApi();

  @override
  Future<DataListPage<UpcomingPageItem>> loadNext( String? pageKey ) async {
    final data = await _webApi.getUpcomingFeedPage(pageKey);

    return data[0];
  }
}
