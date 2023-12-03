import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/service/analytics_service.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/ui/widget/otp_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamuwemu/ui/widget/sign_up.dart';
import 'package:hamuwemu/ui/widget/validate_phone.dart';
import 'package:provider/provider.dart';

const routeValidatePhonePage = 'validate_phone';
const routeOtpPage = 'enter_code';
const routeSignUpPage = 'user_info';

class PhoneSignInPage extends StatefulWidget {
  @override
  _PhoneSignInPageState createState() => _PhoneSignInPageState();
}

class _PhoneSignInPageState extends State<PhoneSignInPage> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final analytics = serviceLocator<AnalyticsService>();
  String currentPage = routeValidatePhonePage;
  late String _initialRoute;

  @override
  void initState() {
    // TODO: implement initState


    super.initState();
  }

  void _onValidationSuccess() {
    _navigatorKey.currentState!.pushNamed(routeOtpPage);
  }

  void _onOtpSuccess() {
    _navigatorKey.currentState!.pushNamed(routeSignUpPage);
  }

  void _completeSignUp() {
    _navigatorKey.currentState!.pushNamed(routeSignUpPage);
  }

  Future<void> _onExitPressed() async {
    final isConfirmed = await _isExitDesired();

    if (isConfirmed && mounted) {
      serviceLocator<AnalyticsService>().logEndPhoneSignUpFlow(currentPage: currentPage);
      _exitSetup();
    }
  }

  Future<bool> _isExitDesired() async {
    return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text(
                'If you exit sign up, your progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Leave'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Stay'),
              ),
            ],
          );
        }) ??
        false;
  }

  void _exitSetup() {
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _isExitDesired,
      child: Scaffold(
        appBar: _buildFlowAppBar(),
        body: Navigator(
          key: _navigatorKey,
          initialRoute: routeValidatePhonePage,
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;
    switch (settings.name) {
      case routeValidatePhonePage:
        page = ValidatePhone(
          onValidationSuccess: _onValidationSuccess,
          completeSignUp: _completeSignUp,
          onFinishSignIn: _exitSetup,
        );
        analytics.logCurrentScreen(
            screenName: settings.name!
        );
        currentPage = settings.name!;
        break;
      case routeOtpPage:
        page = OTPPage(
          onOtpSuccess: _onOtpSuccess,
          onFinishSignIn: _exitSetup,
        );
        analytics.logCurrentScreen(
            screenName: settings.name!
        );
        currentPage = settings.name!;
        break;
      case routeSignUpPage:
        page = SignUp(
          onSignUpSuccess: _exitSetup,
        );
        analytics.logCurrentScreen(
            screenName: settings.name!
        );
        currentPage = settings.name!;
        break;
    }

    return MaterialPageRoute<dynamic>(
      builder: (context) {
        return page;
      },
      settings: settings,
    );
  }

  PreferredSizeWidget _buildFlowAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: _onExitPressed,
        icon: Icon(Icons.chevron_left),
        color: Colors.black,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    );
  }
}



