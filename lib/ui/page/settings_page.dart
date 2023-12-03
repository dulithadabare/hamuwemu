import 'package:hamuwemu/business_logic/view_model/abstract_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/profile_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<UserViewModel>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 16,right: 16,top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("Settings",style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ChangeNotifierProvider<ProfileViewModel>(
                  create: (_) => ProfileViewModel(appModel.user!.firebaseUid!),
                  child: SettingsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SettingHeader(title: 'Profile',),
        Profile(),
        SettingHeader(title: 'Preferences',),
        Preferences(),
      ],
    );
  }
}

class SettingHeader extends StatelessWidget {
  final String title;

  SettingHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Text(title, style: Styles.headerLightGrey36,),
    );
  }
}


class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ProfileViewModel>(context);
    final userModel = Provider.of<UserViewModel>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Column(
        children: [
          ProfileRow(header: 'Name', value: userModel.status == ViewModelStatus.busy ? 'Loading' : userModel.user!.fullName!),
          // ProfileRow(header: 'Partner', value: userModel.status == ViewModelStatus.busy ? 'Loading' : userModel.partner!.fullName),
        ],
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final String header;
  final String? value;
  final GestureTapCallback? onTap;

  ProfileRow({Key? key, required this.header, this.value, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(header, style: Styles.headerBlack18,),
            value != null ? Text(value!, style: Styles.bodyGrey18,) : Container(),
          ],
        ),
      ),
    );
  }
}

class Preferences extends StatelessWidget {

  void _logout(BuildContext context) {
    final appModel = Provider.of<UserViewModel>(context, listen: false);
    appModel.logout();

    // Navigator.of(context).pushNamedAndRemoveUntil(
    //     '/sign-in', (Route<dynamic> route) => false
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileRow(header: 'Log out', onTap: () => _logout(context),),
        ],
      ),
    );
  }
}




