import 'package:hamuwemu/business_logic/model/user_profile.dart';
import 'package:hamuwemu/business_logic/view_model/abstract_view_model.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/database_helper.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

class SettingsViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();

  UserProfile? _userProfile;
  int friendCount = 0;

  UserProfile? get userProfile => _userProfile;

  set userProfile(UserProfile? value) {
    _userProfile = value;

    notifyListeners();
  }

  Future<void> load( String firebaseUid ) async {
    setStatus(ViewModelStatus.busy);
    try {
      DatabaseHelper helper = DatabaseHelper.instance;
      int rowId = 1;
      UserProfileDbModel? userProfileDbModel = await helper.queryUserProfile(firebaseUid);

      userProfile = UserProfile(
        userId: userProfileDbModel?.id,
        firebaseUid: userProfileDbModel?.firebaseUid,
        facebookId: userProfileDbModel?.facebookId,
        displayName: userProfileDbModel?.displayName,
        email: userProfileDbModel?.email,
      );
      setStatus(ViewModelStatus.idle);

      if (userProfileDbModel == null) {
        print('read row $rowId: empty');
      } else {
        print('read row $rowId: ${userProfileDbModel.displayName} ${userProfileDbModel.email}');
      }

    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }

  Future<void> loadFriendCount() async {
    setStatus(ViewModelStatus.busy);
    try {
      final data = await _webApi.getFriendCount();
      friendCount = data[0];
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }
}
