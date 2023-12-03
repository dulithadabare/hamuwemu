import 'package:hamuwemu/business_logic/model/current_status.dart';
import 'package:hamuwemu/business_logic/model/hw_message.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

import 'abstract_view_model.dart';
import 'app_sounds_view_model.dart';

class CurrentStatusViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();

  CurrentStatus? currentStatus;

  Future<void> loadEvent() async {
    setStatus(ViewModelStatus.busy);
    try {
      currentStatus = await _webApi.getCurrentStatus();
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }

  Future<void> addStatus( int? messageId, String content) async {
    HwMessage message = HwMessage(id: messageId, creatorId: -1, content: content);
    CurrentStatus newStatus = CurrentStatus(userId: -1, message: message, timestampUtc: DateTime.now().millisecondsSinceEpoch);
    currentStatus = newStatus;
    addStatusAsync(newStatus);
    setStatus(ViewModelStatus.idle);
    serviceLocator<AppSoundsViewModel>().playAddStatusSound();
  }

  Future<void> addStatusAsync( CurrentStatus newStatus ) async {
    try {
      final data = await _webApi.addStatus(newStatus);
      currentStatus = data;
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }

  Future<void> addMessage( CurrentStatus newStatus, int friendId ) async {
    try {
      final data = await _webApi.addStatus(newStatus);
      currentStatus = data;
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }


  Future<void> removeStatus() async {
    setStatus(ViewModelStatus.busy);
    try {
      final data = await _webApi.removeStatus();
      currentStatus = data;
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }
}
