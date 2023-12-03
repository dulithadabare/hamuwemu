import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';

import '../../styles.dart';
import 'loading_large.dart';

class OTPPage extends StatefulWidget {
  final VoidCallback onOtpSuccess;
  final VoidCallback onFinishSignIn;
  OTPPage({Key? key, required this.onOtpSuccess, required this.onFinishSignIn}) : super(key: key);

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final appModel = serviceLocator<UserViewModel>();
  TextEditingController _smsController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  bool _busy = false;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  void dispose() {
    _smsController.dispose();
    _pinPutFocusNode.dispose();
    super.dispose();
  }

  void signInWithPhoneNumber() async {
    setState(() {
      _busy = true;
    });
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: appModel.verificationId!,
        smsCode: _smsController.text,
      );

      final User? user = (await appModel.auth.signInWithCredential(credential)).user;

      // final newUser = await appModel.checkIfNewUserApi();
      final userExists = await appModel.checkIfUserExists();

      setState(() {
        _busy = false;
      });
      showSnackBar("Successfully signed in UID: ${user?.uid}");

      if(!userExists) {
        widget.onOtpSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Welcome, ${user?.displayName}')));
        widget.onFinishSignIn();
      }
    } catch (e) {
      if(mounted) {
        print("Failed to sign in: " + e.toString());
        showSnackBar("Failed to sign in: " + e.toString());
      }
    }
  }

  void verifyPhoneNumber() async {
    setState(() {
      _busy = true;
    });
    //Callback for when the user has already previously signed in with this phone number on this device
    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      await appModel.auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        _busy = false;
      });
      showSnackBar("Phone number automatically verified and user signed in: ${appModel.auth.currentUser?.uid}");
    };

    //Listens for errors with verification, such as too many attempts
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        _busy = false;
      });
      showSnackBar('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };

    //Callback for when the code is sent
    PhoneCodeSent codeSent =
        (String verificationId, int? forceResendingToken) async {
      setState(() {
        _busy = false;
      });
      showSnackBar('Please check your phone for the verification code.');
      appModel.saveVerificationId(verificationId);
      appModel.saveForceResendToken(forceResendingToken);
      // _verificationId = verificationId;
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      setState(() {
        _busy = false;
      });
      showSnackBar("verification code: " + verificationId);
      appModel.saveVerificationId(verificationId);
    };

    try {
      print('Started Resending Code Flow');
      await appModel.auth.verifyPhoneNumber(
        phoneNumber: appModel.phoneNumber!,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        forceResendingToken: appModel.forceResendToken
      );
    } catch (e) {
      setState(() {
        _busy = false;
      });
      print("Failed to Verify Phone Number: $e");
      showSnackBar("Failed to Verify Phone Number: $e");
    }
  }


  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Enter Code',
                  style: Styles.headerBlack36
              ),
              SizedBox(
                height: 20.0,
              ),
              Text('Enter 6 digit code sent to ${appModel.phoneNumber}',
                  style: Styles.headerLightGrey18
              ),
              SizedBox(
                height: 20.0,
              ),
              _busy ? LoadingLarge() : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PinPut(
                    fieldsCount: 6,
                    onSubmit: (String pin) => signInWithPhoneNumber(),
                    focusNode: _pinPutFocusNode,
                    controller: _smsController,
                    submittedFieldDecoration: _pinPutDecoration.copyWith(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    selectedFieldDecoration: _pinPutDecoration,
                    followingFieldDecoration: _pinPutDecoration.copyWith(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Colors.black.withOpacity(.5),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                      TextButton(
                          onPressed: () => verifyPhoneNumber(),
                          child: Text(
                            "RESEND",
                            style: TextStyle(
                                color: Color(0xFF91D3B3),
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ))
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}