import 'dart:async';
import 'package:hamuwemu/business_logic/data/app_user.dart';
import 'package:hamuwemu/business_logic/model/basic_profile.dart';
import 'package:hamuwemu/business_logic/model/response.dart';
import 'package:hamuwemu/business_logic/model/user_profile.dart';
import 'package:hamuwemu/business_logic/view_model/abstract_view_model.dart';
import 'package:hamuwemu/service/analytics_service.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/database_helper.dart';
import 'package:hamuwemu/service/rtdb_service.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();
  UserProfile? _user;
  BasicProfile? partner;
  bool _signedIn = false;
  bool _initialized = false;
  String? phoneNumber;
  String? verificationId;
  int? forceResendToken;

  Future<void> savePhoneNumber(String authPhoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'authPhoneNumber';
    prefs.setString(key, authPhoneNumber);
    phoneNumber = await readPhoneNumber();
  }

  Future<String?> readPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'authPhoneNumber';
    String? authPhoneNumber = prefs.getString(key);
    print('read $key: $authPhoneNumber');
    return authPhoneNumber;
  }

  void saveVerificationId(String authVerificationID) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'authVerificationID';
    prefs.setString(key, authVerificationID);
    verificationId = await readVerificationId();
  }

  Future<String?> readVerificationId() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'authVerificationID';
    String? authVerificationID = prefs.getString(key);
    print('read $key: $authVerificationID');
    return authVerificationID;
  }

  void saveForceResendToken(int? authForceResendToken) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'authForceResendToken';
    if(authForceResendToken != null) {
      prefs.setInt(key, authForceResendToken);
      forceResendToken = await readForceResendToken();
    }
    else {
      forceResendToken = authForceResendToken;
    }

  }

  Future<int?> readForceResendToken() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'authForceResendToken';
    int? authForceResendToken = prefs.getInt(key);
    print('read $key: $authForceResendToken');
    return authForceResendToken;
  }

  FirebaseAuth get auth => FirebaseAuth.instance;

  bool get signedIn => _signedIn;

  set signedIn(bool value) {
    _signedIn = value;

    notifyListeners();
  }

  bool get initialized => _initialized;

  set initialized(bool value) {
    _initialized = value;

    notifyListeners();
  }

  UserProfile? get user => _user;

  set user(UserProfile? value) {
    _user = value;

    notifyListeners();
  }

  UserViewModel(){
    initialize();
  }

  Future<void> initialize() async {
    setStatus(ViewModelStatus.busy);
    try {
      await Firebase.initializeApp();
      print('Initialized Firebase');

      // If app was closed during verification
      verificationId = await readVerificationId();
      forceResendToken = await readForceResendToken();
      phoneNumber = await readPhoneNumber();

      await initializeAuth();
      print('Initialized Auth');
      initialized = true;
      setStatus(ViewModelStatus.idle);
    } on AccountCreationException catch (e) {
      setStatus(ViewModelStatus.error);
      // return ApiResponse.error('Could not create new account');
    } on FetchDataException catch (e) {
      setStatus(ViewModelStatus.error);
      print(e);
      // _userViewModel.logout();
      // return ApiResponse.error('Could not load user data');
    }  on FirebaseAuthException catch (e) {
      setStatus(ViewModelStatus.error);
      print(e.code);
      // return ApiResponse.error('Could not login to firebase');
    } catch (e) {
      print('Error Initializing FlutterFire');
      print(e);
      setStatus(ViewModelStatus.error);
    }
  }

  Future<void> initializeAuth() async {
    if(auth.currentUser != null ) {
      final userExists = await UserDao().checkIfUserExists();
      if (userExists) {
        print('Uid : ${auth.currentUser?.uid}');
        print('Phone Number : ${auth.currentUser?.phoneNumber}');
        await serviceLocator<AnalyticsService>().logLogin(method: 'phone');
        signedIn = true;
      } else {

      }
    } else {
      print('No signed in user found.');
      // await FirebaseAuth.instance.signInAnonymously();
    }
  }

  Future<ApiResponse<UserProfile>> signUpWithEmailPassword(String email, String password) async {
    try {
      await signUpWithEmailFirebase(email, password);
      await createUser(email, 'Dulitha Dabare');
      await loadUserDataFromApi();
      signedIn = true;
      return ApiResponse.completed('Signed In', user);
    } on FacebookAuthException catch (e) {
      signedIn = false;
      auth.signOut();
      return ApiResponse.error('Could not login to Facebook');
    } on FirebaseLinkingException catch (e) {
      signedIn = false;
      auth.signOut();
      return ApiResponse.error('Linking account with Firebase failed');
    } on AccountCreationException catch (e) {
      signedIn = false;
      auth.signOut();
      return ApiResponse.error('Could not create new account');
    } on FetchDataException catch (e) {
      signedIn = false;
      auth.signOut();
      return ApiResponse.error('Could not load user data');
    }  on FirebaseAuthException catch (e) {
      signedIn = false;
      auth.signOut();
      print(e.code);
      return ApiResponse.error('Could not login to firebase');
    } catch  (e, s) {
      signedIn = false;
      print(e);
      print(s);
      return ApiResponse.error('Error : ${e.toString()}');
    }
  }

  Future<ApiResponse<UserProfile>> signInWithEmailPassword( String email, String password ) async {
    setStatus(ViewModelStatus.busy);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password,);
      await loadUserDataFromApi();
      signedIn = true;
      setStatus(ViewModelStatus.idle);
      return ApiResponse.completed('Signed In', user);
    } on FetchDataException catch (e) {
      signedIn = false;
      setStatus(ViewModelStatus.error);
      return ApiResponse.error('Could not load user data');
    } on FirebaseAuthException catch (e) {
      signedIn = false;
      print(e.code);
      setStatus(ViewModelStatus.error);
      return ApiResponse.error('Could not login to firebase');
    } catch  (e, s) {
      signedIn = false;
      print(e);
      print(s);
      setStatus(ViewModelStatus.error);
      return ApiResponse.error('Error : ${e.toString()}');
    }
  }

  Future<ApiResponse<UserProfile>> signInWithPhone( AuthCredential phoneAuthCredential ) async {
    setStatus(ViewModelStatus.busy);
    try {
      await auth.signInWithCredential(phoneAuthCredential);
      await loadUserDataFromApi();
      signedIn = true;
      setStatus(ViewModelStatus.idle);
      return ApiResponse.completed('Signed In', user);
    } on FetchDataException catch (e) {
      signedIn = false;
      setStatus(ViewModelStatus.error);
      return ApiResponse.error('Could not load user data');
    } on FirebaseAuthException catch (e) {
      signedIn = false;
      print(e.code);
      setStatus(ViewModelStatus.error);
      return ApiResponse.error('Could not login to firebase');
    } catch  (e, s) {
      signedIn = false;
      print(e);
      print(s);
      setStatus(ViewModelStatus.error);
      return ApiResponse.error('Error : ${e.toString()}');
    }
  }

  Future<void> createUser(String email, String name) async {
    try {
      UserProfile newUser = UserProfile(
        email: email,
        displayName: name
      );
      final data = await _webApi.createUser(newUser);
      print('New user account created');
    } on FetchDataException catch (e) {
      print('User account creation failed ${e.toString()}');
      throw AccountCreationException('Cannot create new user ${e.toString()}');
    }
  }

  Future<void> loadUserDataFromApi() async {
    final response = await _getUser();
    if( response.status == ApiResponseStatus.COMPLETED ) {
      user = response.data;

      print('User data loaded ${user?.userId}');
    } else if( response.status == ApiResponseStatus.ERROR ) {
      print('Failed to load user data');
      throw FetchDataException(response.message);
    }

    await _saveUser(user!, partner);
  }

  Future<void> addUser(String firstName, String lastName) async {
    print('Phone no : $phoneNumber');
    final displayName = firstName + ' $lastName';
    // UserProfile newUser = UserProfile(firebaseUid: auth.currentUser?.uid, displayName: firstName, fullName: lastName, phoneNumber: phoneNumber);
    AppUser curr = AppUser(firebaseUid: auth.currentUser!.uid, displayName: displayName, phoneNumber: phoneNumber!);
    await UserDao().addUser(curr);
    await auth.currentUser?.updateDisplayName(displayName);

    signedIn = true;
    setStatus(ViewModelStatus.idle);
  }


  Future<ApiResponse<UserProfile>> addUserApi(String firstName, String lastName) async {
    print('Phone no : $phoneNumber');
    UserProfile newUser = UserProfile(firebaseUid: auth.currentUser?.uid, displayName: firstName, fullName: lastName, phoneNumber: phoneNumber);
    try {
      await _webApi.addUser(newUser);
      await loadUserDataFromApi();
      signedIn = true;
      setStatus(ViewModelStatus.idle);
      return ApiResponse.completed('Signed In', user);
    } on FetchDataException catch (e) {
      print(e);
      return ApiResponse.error(e.toString());
    }
  }

  Future<bool> checkIfNewUserApi() async {
    final response = await _getUser();
    if(response.status == ApiResponseStatus.ERROR) {
      return true;
    }
    await loadUserDataFromApi();
    signedIn = true;
    setStatus(ViewModelStatus.idle);
    serviceLocator<AnalyticsService>().logLogin(method: 'phone');
    return false;
  }

  Future<bool> checkIfUserExists() async {
    return await UserDao().checkIfUserExists();
  }


  Future<ApiResponse<UserProfile>> _getUser() async {
    try {
      final data = await _webApi.getUser();
      return ApiResponse.completed('Loaded User', data[0]);
    } on FetchDataException catch (e) {
      print(e);
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<BasicProfile>> _getPartner() async {
    try {
      final data = await _webApi.getPartner();
      return ApiResponse.completed('Loaded User', data);
    } on FetchDataException catch (e) {
      print(e);
      return ApiResponse.error(e.toString());
    }
  }

  _saveUser(UserProfile user, BasicProfile? partner) async {
    UserProfileDbModel userModel = UserProfileDbModel();
    userModel.id = user.userId;
    userModel.firebaseUid = user.firebaseUid;
    userModel.facebookId = user.facebookId;
    userModel.displayName = user.displayName;
    userModel.email = user.email;
    userModel.fullName = user.fullName;

    if(partner != null) {
      userModel.partnerId = partner.userId;
      userModel.partnerDisplayName = partner.displayName;
      userModel.partnerFullName = partner.fullName;
    }

    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insertUser(userModel);
    print('inserted row: $id');
  }

  loadUserFromLocalStorage(String firebaseUid) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    int rowId = 1;
    UserProfileDbModel? userProfileDbModel = await helper.queryUserProfile(firebaseUid);
    if( userProfileDbModel == null ) {
      await loadUserDataFromApi();
      userProfileDbModel = await helper.queryUserProfile(firebaseUid);
    }

    if(userProfileDbModel != null) {
      user = UserProfile(
        userId: userProfileDbModel.id,
        firebaseUid: userProfileDbModel.firebaseUid,
        displayName: userProfileDbModel.displayName,
        email: userProfileDbModel.email,
        partnerId: userProfileDbModel.partnerId,
        fullName: userProfileDbModel.fullName,
      );

      serviceLocator<AnalyticsService>().setUserProperties(userId: userProfileDbModel.firebaseUid!, userGroup: userProfileDbModel.displayName);

      print('user row $rowId: ${user!.displayName} userId ${user!.userId}');
    }
    else {
      print('user row empty');
    }

  }

  Future<void> signUpWithEmailFirebase( String email, String password ) async {
    AuthCredential emailAuthCredential = EmailAuthProvider.credential(email: email, password: password);
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      print('Created new Firebase user: ${userCredential.user?.email}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print(e.code);
        // Sign the user in with the credential
        await auth.signInWithCredential(emailAuthCredential);
        print('Logged in existing user');
      } else {
        throw e;
      }
    }
  }

  Future<void> logout() async {
    signedIn = false;
    setStatus(ViewModelStatus.busy);
    // await FacebookAuth.instance.logOut();
    try {
      serviceLocator<AnalyticsService>().logLogout(user: user!);
      final token = await FirebaseMessaging.instance.getToken();
      await _webApi.logout(token!);
      await FirebaseAuth.instance.signOut();
      print('Logged out');
      user = null;
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e);
    }
  }
}
