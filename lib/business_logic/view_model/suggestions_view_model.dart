import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hamuwemu/business_logic/model/chat_page_item.dart';
import 'package:hamuwemu/business_logic/model/hw_message.dart';
import 'package:hamuwemu/business_logic/model/suggested_status.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

import 'abstract_view_model.dart';

class SuggestionsViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();
  final battery = Battery();

  HwMessage suggestedStatus = HwMessage(creatorId: -1, content: '🧘 Chilling');
  // List<HwMessage> suggestionList = [];


  SuggestionsViewModel(){
    load();
  }

  List<SuggestedStatus> suggestionsList = <SuggestedStatus>[
    SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '🍔 Having Dinner')),
    SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '🏃 On the move')),
    SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '🌮 Having Lunch')),
    SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '🌜 Sleep')),
    SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '💉 Vaccinated')),
    SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '👩‍💻 Busy')),
    SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '‍🏖 Relaxing')),
  ];

  Future<void> loadFromApi() async {
    setStatus(ViewModelStatus.busy);
    try {
      final data = await _webApi.getSuggestions();
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }

  void load() async {
    setStatus(ViewModelStatus.busy);
    suggestionsList = [];
    final currDt = DateTime.now();
    try {
      final batteryLevel = await battery.batteryLevel;
      print('Battery Level $batteryLevel');
      if(batteryLevel < 20) {
        suggestedStatus = HwMessage(creatorId: -1, content: '🔋 Low Battery');
        setStatus(ViewModelStatus.idle);
        return;
      }
    } catch (e) {
      print(e);
    }
    // var connectivityResult = await (Connectivity().checkConnectivity());

    if(currDt.hour < 8) {
      suggestedStatus = HwMessage(creatorId: -1, content: '🌤 Good Morning');

      suggestionsList = <SuggestedStatus>[
        SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '🌤 Good Morning')),
        SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '🌯 Having Breakfast')),
        SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '👩‍💻 Started Working')),
      ];
    } else if(currDt.hour >= 8 && currDt.hour < 10 ) {
      suggestedStatus = HwMessage(creatorId: -1, content: '🌯 Having Breakfast');

      suggestionsList = <SuggestedStatus>[
        SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '🌤 Good Morning')),
        SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '🌯 Having Breakfast')),
        SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '👩‍💻 Started Working')),
      ];
    } else if(currDt.hour >= 10 && currDt.hour < 12 ) {
      suggestedStatus = HwMessage(creatorId: -1, content: '👩‍⚕️In the Wards');

      suggestionsList = <SuggestedStatus>[
        SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '👩‍⚕️In the Wards')),
        SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '🌯 Having Breakfast')),
        SuggestedStatus(averageSentTime: 0, lastSentTime: 0, message: HwMessage(creatorId: -1, content: '👩‍💻 Started Working')),
      ];
    } else if(currDt.hour >= 12 && currDt.hour < 14 ) {
      suggestedStatus = HwMessage(creatorId: -1, content: '🌮 Having Lunch');
    } else if(currDt.hour >= 14 && currDt.hour < 16 ) {
      suggestedStatus = HwMessage(creatorId: -1, content: '👩‍💻 Busy');
    } else if(currDt.hour >= 16 && currDt.hour < 18 ) {
      suggestedStatus = HwMessage(creatorId: -1, content: '☕ Tea Time️');
    } else if(currDt.hour >= 18 && currDt.hour < 20 ) {
      suggestedStatus = HwMessage(creatorId: -1, content: '🍔 Having Dinner');
    } else if(currDt.hour >= 20 && currDt.hour < 24 ) {
      suggestedStatus = HwMessage(creatorId: -1, content: '🌜 Good Night');
    }

    // suggestionsList.add(HwMessage(creatorId: -1, content: '🌤 Good Morning'));
    // suggestionsList.add(HwMessage(creatorId: -1, content: '🌯 Having Breakfast'));
    // suggestionsList.add(HwMessage(creatorId: -1, content: '👩‍⚕️In the Wards'));
    // suggestionsList.add(HwMessage(creatorId: -1, content: '🌮 Having Lunch'));
    // suggestionsList.add(HwMessage(creatorId: -1, content: '👩‍💻 Busy'));
    // suggestionsList.add(HwMessage(creatorId: -1, content: '☕ Tea Time️'));
    // suggestionsList.add(HwMessage(creatorId: -1, content: '🍔 Having Dinner'));
    // suggestionsList.add(HwMessage(creatorId: -1, content: '🌜 Good Night'));


    setStatus(ViewModelStatus.idle);
  }
}
