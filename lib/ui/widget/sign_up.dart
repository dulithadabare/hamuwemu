import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hamuwemu/business_logic/model/response.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/service/analytics_service.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/ui/widget/rounded_button.dart';

import '../../styles.dart';

class SignUp extends StatefulWidget {
  final VoidCallback onSignUpSuccess;
  const SignUp({Key? key, required this.onSignUpSuccess}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormBuilderState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  bool _error = false;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _signUp( BuildContext context ) async {
    setState(() {
      _error = false;
      _message = null;
      _busy = true;
    });
    final appModel = serviceLocator<UserViewModel>();
    try {
      await appModel.addUser(_firstNameController.text, _lastNameController.text);

      setState(() {
            _error = false;
            _message = null;
            _busy = false;
          });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Welcome, ${appModel.auth.currentUser?.displayName}')));
      serviceLocator<AnalyticsService>().logSignUp(method: 'phone');
      widget.onSignUpSuccess();
    } catch (e) {
      print(e);
      setState(() {
        _error = true;
        _message = e.toString();
        _busy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not complete sign up. Error : $e')));
    }
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
            children: [
              Text('Almost done!',
                  style: Styles.headerBlack36
              ),
              SizedBox(
                height: 20.0,
              ),
              Text('Enter your details so we can make you a new account',
                  style: Styles.headerLightGrey18
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  FormBuilder(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: <Widget>[
                        FormBuilderTextField(
                          name: 'firstName',
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText:
                            'First Name',
                          ),
                          // valueTransformer: (text) => num.tryParse(text),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.max(context, 70),
                          ]),
                          keyboardType: TextInputType.text,
                        ),
                        FormBuilderTextField(
                          name: 'lastName',
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText:
                            'Last Name',
                          ),
                          // valueTransformer: (text) => num.tryParse(text),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.max(context, 70),
                          ]),
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: RoundedButton(
                            buttonLabel: 'Complete Sign Up',
                            onPressed: () {
                              _formKey.currentState?.save();
                              if (_formKey.currentState!.validate()) {
                                print(_formKey.currentState?.value);
                                _signUp(context);
                              } else {
                                print("validation failed");
                              }
                            },
                            loading: _busy
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
