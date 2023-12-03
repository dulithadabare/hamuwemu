import 'package:flutter/cupertino.dart';
import 'package:hamuwemu/business_logic/view_model/abstract_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/partner_active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/styles.dart';
import 'package:hamuwemu/ui/page/add_update_page.dart';
import 'package:flutter/material.dart';
import 'package:hamuwemu/ui/widget/leave_button.dart';
import 'package:hamuwemu/ui/widget/loading_large.dart';
import 'package:hamuwemu/ui/widget/rounded_button.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class UpdateCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final event = pageItem.event;
    // final createdDt = DateTime.fromMillisecondsSinceEpoch(pageItem.timestampUtc);
    // final createdTimeAgo = timeago.format(createdDt);
    //
    // String title = '${event.activity.characters.first.toLowerCase()}${event.activity.substring(1)}';

    final model = Provider.of<ActiveEventViewModel>(context);
    String description =  '';
    TextStyle? titleTextStyle = Styles.headerLightGrey36;
    String createdTimeAgo = '';
    String likedBy = '';
    bool noEvent = true;
    if(model.status != ViewModelStatus.busy && model.activeEvent != null) {
      description = model.activeEvent!.event.description ?? 'No Event';
      if(model.activeEvent!.event.description != null ) {
        titleTextStyle = Styles.headerBlack36;
        noEvent = false;
      }
      final createdDt = DateTime.fromMillisecondsSinceEpoch(model.activeEvent!.event.timestampUtc);
      createdTimeAgo = timeago.format(createdDt);

      if(model.activeEvent!.event.likedUserList.isNotEmpty) {
        likedBy = 'Liked by ${model.activeEvent!.event.likedUserList.first.displayName}';
      }
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
              child: model.status == ViewModelStatus.busy ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingLarge(),
                ],
              ) : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        createdTimeAgo,
                        style: Styles.headerGrey18,
                      ),
                      noEvent ? Container() : LeaveButton(),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          description,
                          style: titleTextStyle,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        likedBy,
                        style: Styles.headerGrey18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PartnerUpdateCard extends StatelessWidget {
  // final int userId;
  //
  // UpdateCard({Key? key, required this.userId}) : super(key: key);
  Future<void> _like(BuildContext context, bool isLiked) async {
    final model = Provider.of<PartnerActiveEventViewModel>(context, listen: false);
    isLiked ? await model.removeLike() : await model.like();
  }

  Future<bool> onLikeButtonTapped(BuildContext context, bool isLiked) async {
    print('New like : $isLiked');
    /// send your request here
    // final bool success= await sendRequest();
    _like(context, isLiked);


    /// if failed, you can do nothing
    return !isLiked;
  }

  @override
  Widget build(BuildContext context) {
    // final event = pageItem.event;
    // final createdDt = DateTime.fromMillisecondsSinceEpoch(pageItem.timestampUtc);
    // final createdTimeAgo = timeago.format(createdDt);
    //
    // String title = '${event.activity.characters.first.toLowerCase()}${event.activity.substring(1)}';

    final model = Provider.of<PartnerActiveEventViewModel>(context);
    String description =  '';
    TextStyle? titleTextStyle = Styles.headerLightGrey36;
    String createdTimeAgo = '';
    String likedBy = '';
    bool liked = false;
    bool noEvent = false;
    if(model.status != ViewModelStatus.busy && model.activeEvent != null) {
      description = model.activeEvent!.event.description ?? 'No Event';
      if(model.activeEvent!.event.description != null ) {
        titleTextStyle = Styles.headerBlack36;
      } else {
        noEvent = true;
      }
      final createdDt = DateTime.fromMillisecondsSinceEpoch(model.activeEvent!.event.timestampUtc);
      createdTimeAgo = timeago.format(createdDt);
      if(model.activeEvent!.event.likedUserList.isNotEmpty) {
        likedBy = 'Liked by ${model.activeEvent!.event.likedUserList.first.displayName}';
      }
      liked = model.activeEvent!.liked;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: null,
            child: SizedBox(
              height: 200,
              child: Container(
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                child: model.status == ViewModelStatus.busy ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingLarge(),
                  ],
                ) : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          createdTimeAgo,
                          style: Styles.headerGrey18,
                        ),
                        noEvent? Container() : JoinButton(description: model.activeEvent?.event.description)
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            description,
                            style: titleTextStyle,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          likedBy,
                          style: Styles.headerGrey18,
                        ),
                        noEvent? Container() : LikeButton(
                          onTap: (isLiked) => onLikeButtonTapped(context, isLiked),
                          isLiked: liked,
                          likeCount: null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class JoinButton extends StatefulWidget {
  final String? description;

  const JoinButton({Key? key, required this.description}) : super(key: key);

  @override
  _JoinButtonState createState() => _JoinButtonState();
}

class _JoinButtonState extends State<JoinButton> {
  bool _loading = false;

  void _join() async {
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    final model = Provider.of<ActiveEventViewModel>(context, listen: false);

    setState(() {
      _loading = true;
    });
    await model.joinEvent(userModel.user!.userId!, widget.description);
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String buttonLabel = 'Join';
    VoidCallback onPressed =  () => _join();

    return RoundedButton( buttonLabel: buttonLabel, onPressed: onPressed, loading: _loading, );
  }
}