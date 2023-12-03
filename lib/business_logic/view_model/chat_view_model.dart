import 'package:hamuwemu/business_logic/model/active_event.dart';
import 'package:hamuwemu/business_logic/model/active_event_response.dart';
import 'package:hamuwemu/business_logic/model/chat_page_item.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

import 'abstract_view_model.dart';

class ChatViewModel extends AbstractViewModel {
  ChatPageItem chatPageItem;

  ChatViewModel(this.chatPageItem);
}
