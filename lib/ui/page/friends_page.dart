import 'package:badges/badges.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:hamuwemu/business_logic/model/chat_page_item.dart';
import 'package:hamuwemu/business_logic/model/event_history_page_item.dart';
import 'package:hamuwemu/business_logic/model/hw_message.dart';
import 'package:hamuwemu/business_logic/model/user_profile.dart';
import 'package:hamuwemu/business_logic/view_model/abstract_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/current_status_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/friends_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/event_history_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/service/analytics_service.dart';
import 'package:hamuwemu/service/contact_service.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/styles.dart';
import 'package:hamuwemu/ui/page/add_friends_page.dart';
import 'package:hamuwemu/ui/page/chat_page.dart';
import 'package:hamuwemu/ui/page/friend_histoy_page.dart';
import 'package:hamuwemu/ui/widget/add_button.dart';
import 'package:hamuwemu/ui/widget/error_message.dart';
import 'package:flutter/material.dart';
import 'package:hamuwemu/ui/widget/loading_large.dart';
import 'package:hamuwemu/ui/widget/rounded_button.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendsPage extends StatelessWidget {
  // void _pushAddFriends(BuildContext context) async {
  //   final analytics = serviceLocator<AnalyticsService>();
  //   serviceLocator<AnalyticsService>().logCurrentScreen(screenName: 'Add Friends');
  //
  //  Set<int>? friendIdList = await Navigator.of(context).push(
  //     MaterialPageRoute<Set<int>>(
  //       fullscreenDialog: true,
  //       builder: (BuildContext context) {
  //         return AddFriendsPage();
  //       }, // ...to here.
  //     ),
  //   );
  //
  //  if(friendIdList != null && friendIdList.isNotEmpty) {
  //    final model = Provider.of<FriendsViewModel>(context, listen: false);
  //    await model.addFriends(friendIdList);
  //    model.load();
  //    serviceLocator<AnalyticsService>().logAddFriends(count: friendIdList.length);
  //  } else {
  //    serviceLocator<AnalyticsService>().logExitAddFriends();
  //  }
  // }

  void _pushAddFriends(BuildContext context) async {
    final analytics = serviceLocator<AnalyticsService>();
    serviceLocator<AnalyticsService>().logCurrentScreen(screenName: 'Add Friends');

    Set<UserProfile>? friendIdList = await Navigator.of(context).push(
      MaterialPageRoute<Set<UserProfile>>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return AddFriendsPage();
        }, // ...to here.
      ),
    );

    if(friendIdList != null && friendIdList.isNotEmpty) {
      final model = Provider.of<FriendsViewModel>(context, listen: false);
      await model.addFriendReq(friendIdList.toList());
      model.load();
      serviceLocator<AnalyticsService>().logAddFriends(count: friendIdList.length);
    } else {
      serviceLocator<AnalyticsService>().logExitAddFriends();
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<FriendsViewModel>(context, listen: false);

    // return Scaffold(
    //   body: SingleChildScrollView(
    //     physics: BouncingScrollPhysics(),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: <Widget>[,
    //         Padding(
    //           padding: EdgeInsets.only(top: 16,left: 16,right: 16),
    //           child: TextField(
    //             decoration: InputDecoration(
    //               hintText: "Search...",
    //               hintStyle: TextStyle(color: Colors.grey.shade600),
    //               prefixIcon: Icon(Icons.search,color: Colors.grey.shade600, size: 20,),
    //               filled: true,
    //               fillColor: Colors.grey.shade100,
    //               contentPadding: EdgeInsets.all(8),
    //               enabledBorder: OutlineInputBorder(
    //                   borderRadius: BorderRadius.circular(20),
    //                   borderSide: BorderSide(
    //                       color: Colors.grey.shade100
    //                   )
    //               ),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Friends",style: Styles.pageHeader,),
                      GestureDetector(
                        onTap: () => _pushAddFriends(context),
                        child: Container(
                          padding: EdgeInsets.only(left: 8,right: 8,top: 2,bottom: 2),
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.pink[50],
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.add,color: Colors.pink,size: 20,),
                              SizedBox(width: 2,),
                              Text("Add",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                    onRefresh: () => Future.sync(
                          () => model.load(),
                    ),
                    child: ChatList(
                      pushAddFriendsPage: _pushAddFriends,
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

class ChatList extends StatelessWidget {
  final void Function(BuildContext context) pushAddFriendsPage;
  const ChatList({Key? key, required this.pushAddFriendsPage}) : super(key: key);

  void _addStatus(BuildContext context, HwMessage message) async {
    final model = Provider.of<CurrentStatusViewModel>(context, listen: false);
    model.addStatus(message.id, message.content);
    await serviceLocator<AnalyticsService>().logAddFriendStatus(message: message);
    final snackBar = SnackBar(content: Text('Updated Status \'${model.currentStatus?.message?.content}\''));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<FriendsViewModel>(context);
    if(model.status == ViewModelStatus.busy) {
      return Center(
          child: LoadingLarge()
      );
    } else if (model.status == ViewModelStatus.error) {
      return ErrorState(title: 'Oops', subtitle: 'Something went wrong');
    }

    final contacts = serviceLocator<ContactService>();

    // if(model.chatPageItemList.isEmpty) return Center(
    //   child: RoundedButton(
    //     buttonLabel: 'Add Friends',
    //     onPressed: () => pushAddFriendsPage(context),
    //     loading: false,
    //   ),
    // );

    if(model.chatPageItemList.isEmpty) return EmptyState(title: 'No Friends', subtitle: 'Looks like you haven\'t added any friends yet', onPressed: () => pushAddFriendsPage(context));

    // print('DisplayNameMap ${contacts.displayNameMap}');

    final tiles = model.chatPageItemList.map(
      (ChatPageItem chatPageItem) {
        // print('Friend Phone Number ${chatPageItem.friend.phoneNumber}');
        String title =
            contacts.getDisplayNameFromAppUser(chatPageItem.friend) ??
                chatPageItem.friend.phoneNumber!;

        String subtitle = 'No Status';
        int lastTimeStamp = 0;
        VoidCallback? _onDoubleTap;

        final receivedMessage = chatPageItem.receivedMessage;
        bool showJoinButton = receivedMessage?.message != null;
        if (receivedMessage != null) {
          subtitle = receivedMessage.message?.content ?? 'No Status';
          lastTimeStamp = receivedMessage.timestampUtc;
          _onDoubleTap = receivedMessage.message != null
              ? () => _addStatus(context, receivedMessage.message!)
              : null;
        }

        final createdDt = DateTime.fromMillisecondsSinceEpoch(lastTimeStamp);
        String timeStamp = timeago.format(createdDt);
        lastTimeStamp != 0 ? Text(timeStamp) : Text('');

        // return ConversationList( chatPageItem: chatPageItem, name: title, messageText: subtitle, time: timeStamp, isMessageRead: chatPageItem.seen);

        return ListTile(
          // leading: chatPageItem.seen ?  CircleAvatar(
          //   backgroundColor: Colors.brown.shade800,
          //   child: Text(chatPageItem.friend.displayName!.characters.first.toUpperCase()),
          // ) : Badge(
          //   child: CircleAvatar(
          //     backgroundColor: Colors.brown.shade800,
          //     child: Text(chatPageItem.friend.displayName!.characters.first.toUpperCase()),
          //   ),
          // ),
          title: Text(
            title,
            style: Styles.listTitle,
          ),
          subtitle: Text(
            subtitle,
            style: chatPageItem.seen ? Styles.listSubtitleLight : Styles.listSubtitle,
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: _onDoubleTap,
                  color: Colors.black,
                  icon: Icon(
                    Icons.add,
                  )),
            ],
          ),
        );
      },
    );

    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return ListView(children: divided);
  }
}

class ConversationList extends StatefulWidget{
  final ChatPageItem chatPageItem;
  final String name;
  final String messageText;
  final String? imageUrl;
  final String time;
  final bool isMessageRead;
  ConversationList({required this.chatPageItem,required this.name,required this.messageText,this.imageUrl,required this.time,required this.isMessageRead});
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  void _pushHistoryPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<int>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return FriendHistoryPage(
            name: widget.name,
              status: widget.messageText,
              historyUserId: widget.chatPageItem.friend.userId!
          );
        },
        settings: RouteSettings(name: 'FriendHistoryPage'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  // widget.imageUrl == null ? CircleAvatar(
                  //   backgroundColor: Colors.brown.shade800,
                  //   child: Text(widget.name.characters.first.toUpperCase()),
                  // ) : CircleAvatar(
                  //   backgroundImage: NetworkImage(widget.imageUrl!),
                  //   maxRadius: 30,
                  // ),
                  // SizedBox(width: 16,),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.name, style: Styles.listTitle,),
                              AddButton(
                                messageId: widget.chatPageItem.receivedMessage?.message?.id,
                                  messageContent: widget.chatPageItem.receivedMessage?.message?.content
                              ),
                              // Text(widget.time, style: Styles.headerLightGrey18,),
                            ],
                          ),
                          SizedBox(height: 6,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.messageText,style:  widget.isMessageRead ? Styles.listSubtitleLight : Styles.listSubtitle,),
                            ],
                          ),
                          // Text(widget.messageText,style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text(widget.time,style: TextStyle(fontSize: 12,fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
          ],
        ),
      ),
    );
  }
}


