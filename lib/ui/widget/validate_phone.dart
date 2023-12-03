import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/ui/widget/rounded_button.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

import '../../styles.dart';

class ValidatePhone extends StatefulWidget {
  final VoidCallback onValidationSuccess;
  final VoidCallback completeSignUp;
  final VoidCallback onFinishSignIn;
  ValidatePhone({Key? key, required this.onValidationSuccess, required this.onFinishSignIn, required this.completeSignUp}) : super(key: key);

  @override
  _ValidatePhoneState createState() => _ValidatePhoneState();
}

class _ValidatePhoneState extends State<ValidatePhone> {
  bool _busy = false;

  final TextEditingController _phoneController = TextEditingController();
  final String initialCountry = 'LK';
  PhoneNumber _number = PhoneNumber(isoCode: 'LK');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  void verifyPhoneNumber() async {
    setState(() {
      _busy = true;
    });
    final appModel = serviceLocator<UserViewModel>();
    // print('Verify Number : ${_number.phoneNumber!}');
    await appModel.savePhoneNumber(_number.phoneNumber!);
    //Callback for when the user has already previously signed in with this phone number on this device
    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      final userCredential = await appModel.auth.signInWithCredential(phoneAuthCredential);
      final userExists = await appModel.checkIfUserExists();

      setState(() {
        _busy = false;
      });
      // showSnackBar("Phone number automatically verified and user signed in: ${appModel.auth.currentUser?.uid}");

      if(!userExists) {
        widget.completeSignUp();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Welcome, ${userCredential.user?.displayName}')));
        widget.onFinishSignIn();
      }
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
      widget.onValidationSuccess();
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
      print('Started verification');
      await appModel.auth.verifyPhoneNumber(
        phoneNumber: appModel.phoneNumber!,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        // forceResendingToken: appModel.forceResendToken
      );
      print('verification done');
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter Your Phone Number',
                  style: Styles.pageHeader
              ),
              SizedBox(
                height: 10.0,
              ),
              Text('We will send an OTP to the specified number to verify that it\'s really you ',
                  style: Styles.listTitle
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    InternationalPhoneNumberInput(
                      countries: ['LK','US'],
                      onInputChanged: (PhoneNumber number) {
                        _number = number;
                        print(number.phoneNumber);
                      },
                      onInputValidated: (bool value) {
                        print('Validated $value');
                      },
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.DROPDOWN,

                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: TextStyle(color: Colors.black),
                      initialValue: _number,
                      textFieldController: _phoneController,
                      formatInput: true,
                      keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                      // inputBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                      onSaved: (PhoneNumber number) {
                        number.parseNumber();
                        print('On Saved: $number');
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    RoundedButton(
                      onPressed: () async => verifyPhoneNumber(),
                      buttonLabel: ' Verify Number ',
                      loading: _busy,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}