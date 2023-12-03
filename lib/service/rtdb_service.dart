import 'package:hamuwemu/business_logic/data/app_user.dart';
import 'package:hamuwemu/business_logic/data/location.dart';
import 'package:hamuwemu/business_logic/model/user_profile.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/service/service_locator.dart';

class LocationDao {
  // final DatabaseReference _locationsRef = FirebaseDatabase(databaseURL: 'https://dosomething-901eb-default-rtdb.asia-southeast1.firebasedatabase.app').reference().child('locations');

  void addLocation(Location curr) {
    final uid = serviceLocator<UserViewModel>().auth.currentUser!.uid;
    // _locationsRef.child(uid) .push().set(curr.toJson());
  }

  // Query getLocationQuery() {
  //   return _locationsRef;
  // }
}

class UserDao {
  // final DatabaseReference _usersRef = FirebaseDatabase(databaseURL: 'https://dosomething-901eb-default-rtdb.asia-southeast1.firebasedatabase.app').reference().child('users');

  Future addUser(AppUser curr) async {
    // await _usersRef.child(curr.firebaseUid).set(curr.toJson());
  }

  Future<bool> checkIfUserExists() async {
    final uid = serviceLocator<UserViewModel>().auth.currentUser!.uid;
    // final snap = await _usersRef.orderByKey().equalTo(uid).once();
    return false;
  }

  Future<AppUser> getUser(String firebaseUid) async {
    // final snap = await _usersRef.orderByKey().equalTo(firebaseUid).once();
    // final json = snap.value as Map<String, dynamic>;

    return AppUser.fromJson( Map<String, dynamic>());
  }

}