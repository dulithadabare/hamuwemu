import 'package:flutter/cupertino.dart';
import 'package:hamuwemu/business_logic/view_model/active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/current_activity_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/partner_active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/styles.dart';
import 'package:flutter/material.dart';
import 'package:hamuwemu/ui/widget/rounded_button.dart';
import 'package:hamuwemu/ui/widget/update_card.dart';
import 'package:provider/provider.dart';

import 'add_update_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  void _pushCreate(BuildContext context) async {
    final eventId = await Navigator.of(context).push(
      MaterialPageRoute<int>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return AddUpdatePage();
        }, // ...to here.
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    final activeModel = Provider.of<ActiveEventViewModel>(context, listen: false);
    final partnerModel = Provider.of<PartnerActiveEventViewModel>(context, listen: false);

    final userDisplayName = userModel.user!.displayName!;
    final partnerDisplayName = userModel.partner!.displayName!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Now',
                      style: Styles.headerBlack36,
                    ),
                    IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _pushCreate(context))
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => Future.sync(
                        () {
                      activeModel.loadEvent();
                      partnerModel.loadEvent();
                    },
                  ),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partnerDisplayName,
                              style: Styles.headerGrey36,
                            ),
                            PartnerUpdateCard(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userDisplayName,
                              style: Styles.headerGrey36,
                            ),
                            UpdateCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


