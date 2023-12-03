import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

import 'abstract_view_model.dart';

class AppSoundsViewModel extends AbstractViewModel {
  Soundpool? _pool;
  int? _notificationSoundId;
  int? _addStatusSoundId;


  AppSoundsViewModel(){
    _loadSoundpool();
  }

  _loadSoundpool() async {
    _pool = Soundpool.fromOptions(options: SoundpoolOptions(
        streamType: StreamType.notification
    ));
    _notificationSoundId = await rootBundle.load('assets/notification.wav').then((ByteData soundData) {
      return _pool!.load(soundData);
    });
    _addStatusSoundId = await rootBundle.load('assets/add_status.wav').then((ByteData soundData) {
      return _pool!.load(soundData);
    });
  }

  void playNotificationSound() {
    if(_pool != null && _notificationSoundId != null ) _pool!.play(_notificationSoundId!);
  }

  void playAddStatusSound() {
    if(_pool != null && _addStatusSoundId != null ) _pool!.play(_addStatusSoundId!);
  }
}
