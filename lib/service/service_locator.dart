import 'package:get_it/get_it.dart';
import 'package:hamuwemu/business_logic/view_model/active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/app_sounds_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/friends_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/partner_active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/suggestions_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/service/analytics_service.dart';

import 'contact_service.dart';

GetIt serviceLocator = GetIt.instance;

// 2
void setupServiceLocator() {

  // 3
  // serviceLocator.registerLazySingleton<StorageService>(() => StorageServiceImpl());
  // serviceLocator.registerLazySingleton<WebApi>(() => WebApi());
  serviceLocator.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  serviceLocator.registerLazySingleton<ContactService>(() => ContactService());

  // 4
  serviceLocator.registerSingleton<UserViewModel>(UserViewModel());
  // serviceLocator.registerSingleton<AppViewModel>(AppViewModel()); // AppViewModel depends on UserViewModel
  serviceLocator.registerSingleton<FriendsViewModel>(FriendsViewModel());
  serviceLocator.registerSingleton<PartnerActiveEventViewModel>(PartnerActiveEventViewModel());
  serviceLocator.registerSingleton<ActiveEventViewModel>(ActiveEventViewModel());
  serviceLocator.registerSingleton<AppSoundsViewModel>(AppSoundsViewModel());
  serviceLocator.registerSingleton<SuggestionsViewModel>(SuggestionsViewModel());
}