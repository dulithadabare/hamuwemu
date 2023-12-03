import 'package:hamuwemu/business_logic/model/hw_message.dart';
import 'package:hamuwemu/business_logic/model/suggested_status.dart';
import 'package:hamuwemu/business_logic/view_model/abstract_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/current_status_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/suggestions_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/service/analytics_service.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/styles.dart';
import 'package:hamuwemu/ui/page/add_status_page.dart';
import 'package:flutter/material.dart';
import 'package:hamuwemu/ui/widget/loading_large.dart';
import 'package:hamuwemu/ui/widget/rounded_button.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:swipe_cards/swipe_cards.dart';

class Content {
  final String text;
  final Color color;

  Content({required this.text, required this.color});
}

class StatusPage extends StatefulWidget {
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final suggestionsModel = serviceLocator<SuggestionsViewModel>();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<String> _names = ["Red", "Blue", "Green", "Yellow", "Orange"];
  List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange
  ];

  void _refreshSuggestions() {
    suggestionsModel.load();
  }

  void _removeCard(int index) {
    suggestionsModel.suggestionsList.removeAt(index);
    suggestionsModel.setStatus(ViewModelStatus.idle);
  }

  List<Widget> _buildCards() {
    List<Widget> cardList = [];
    final cards = suggestionsModel.suggestionsList.map((item) => SuggestionSwipeCard(message: item.message)).toList();
    for (int x = 0; x < 3; x++) {
      cardList.add(Positioned(
        child: Draggable(
          onDragEnd: (drag){
            _removeCard(x);
          },
          childWhenDragging: Container(),
          feedback: cards[x],
          child: cards[x],
        ),
      )
      );
    }

    return cardList;
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = Provider.of<SuggestionsViewModel>(context);
    final model = Provider.of<CurrentStatusViewModel>(context);
    final userModel = Provider.of<UserViewModel>(context);
    final status = model.currentStatus?.message?.content ?? 'No Status';
    final displayName = userModel.user?.displayName ?? 'No Name';
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(displayName,style: Styles.pageHeader,),
                          // InkWell(
                          //   onTap: () => _pushCreate(context),
                          //   child: Container(
                          //     padding: EdgeInsets.only(left: 8,right: 8,top: 2,bottom: 2),
                          //     height: 30,
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(30),
                          //       color: Colors.pink[50],
                          //     ),
                          //     child: Row(
                          //       children: <Widget>[
                          //         Icon(Icons.add,color: Colors.pink,size: 20,),
                          //         SizedBox(width: 2,),
                          //         Text("Add New",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      Text(status,style: Styles.listTitle,),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Column(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       Text('Double Tap to Send', style: Styles.headerLightGrey36,),
                        //       Icon(Icons.arrow_downward_sharp, color: Color(0xFFE5E5E5), size: 36.0,),
                        //     ],
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: <Widget>[
                        //       Text("Status",
                        //         style: Styles.pageHeaderLightGrey,
                        //       ),
                        //       InkWell(
                        //         onTap: () => _pushCreate(context),
                        //         child: Container(
                        //           padding: EdgeInsets.only(left: 8,right: 8,top: 2,bottom: 2),
                        //           height: 30,
                        //           decoration: BoxDecoration(
                        //             borderRadius: BorderRadius.circular(30),
                        //             color: Colors.pink[50],
                        //           ),
                        //           child: Row(
                        //             children: <Widget>[
                        //               Icon(Icons.add,color: Colors.pink,size: 20,),
                        //               SizedBox(width: 2,),
                        //               Text("Add New",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Suggested',style: Styles.pageHeaderLightGrey,),
                            IconButton(
                              color: Colors.black,
                                onPressed: () => _refreshSuggestions(),
                                icon: Icon(Icons.refresh)),
                          ],
                        ),
                        // SwipeCards(
                        //   matchEngine: _matchEngine,
                        //   itemBuilder: (BuildContext context, int index) {
                        //     return SuggestionSwipeCard(message: _swipeItems[index].content);
                        //     return Container(
                        //       alignment: Alignment.center,
                        //       color: _swipeItems[index].content.color,
                        //       child: Text(
                        //         _swipeItems[index].content.text,
                        //         style: TextStyle(fontSize: 100),
                        //       ),
                        //     );
                        //   },
                        //   onStackFinished: () {
                        //     print('Stack Finished');
                        //   },
                        // ),
                        // Stack(
                        //   children: _buildCards(),
                        // ),
                        // StackedCardCarousel(
                        //   items: _buildCards(),
                        // ),
                        // SuggestionSwipeStack(),
                        CurrentStatusCard(),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Column(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       Icon(Icons.arrow_upward_sharp, color: Color(0xFFE5E5E5), size: 36.0,),
                        //       Text('Tap to Edit', style: Styles.pageHeader,),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              // Text('Suggested', style: Styles.headerLightGrey36,),
              // Expanded(
              //   child: StatusSuggestionsList(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentStatusCard extends StatelessWidget {
  final suggestModel = serviceLocator<SuggestionsViewModel>();

  void _pushCreate(BuildContext context) async {
    serviceLocator<AnalyticsService>().logCurrentScreen(screenName: 'Add Status Page');
    Navigator.of(context).push(
      MaterialPageRoute<int>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return AddStatusPage( message: suggestModel.suggestedStatus,);
        },
        settings: RouteSettings(name: 'AddStatusPage'),
      ),
    );
  }

  void _send(BuildContext context) {
    final model = Provider.of<CurrentStatusViewModel>(context, listen: false);
    model.addStatus(suggestModel.suggestedStatus.id, suggestModel.suggestedStatus.content);
    final snackBar = SnackBar(content: Text('Updated Status \'${model.currentStatus?.message?.content}\''));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    serviceLocator<AnalyticsService>().logSendSuggestedToAll(message: model.currentStatus!.message!);
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<SuggestionsViewModel>(context);

    return GestureDetector(
      onDoubleTap: () => _send(context),
      onTap: () => _pushCreate(context),
      child: Card(
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
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            model.suggestedStatus.content,
                            style: Styles.pageHeader,
                          ),
                        ),
                      ),
                    ),
                    Text('Double Tap to Send. Tap to Edit.', style: Styles.tipLightGrey,),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       likedBy,
                    //       style: Styles.headerGrey18,
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusSuggestionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<SuggestionsViewModel>(context);
    final tiles = model.suggestionsList.map(
          (SuggestedStatus feedItem) {
        return SuggestionListCard(suggestedStatus: feedItem);
      },
    );

    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return ListView(children: divided);
  }
}

class SuggestionListCard extends StatelessWidget {
  final SuggestedStatus suggestedStatus;
  const SuggestionListCard({Key? key, required this.suggestedStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String description =  suggestedStatus.message.content;
    TextStyle? titleTextStyle = Styles.headerLightGrey36;

    final createdDt = DateTime.fromMillisecondsSinceEpoch(suggestedStatus.lastSentTime);
    String createdTimeAgo = timeago.format(createdDt);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  description,
                  style: Styles.headerBlack18,
                ),
                AddButton(
                  messageId: suggestedStatus.message.id,
                  messageContent: suggestedStatus.message.content,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RemoveButton extends StatefulWidget {
  const RemoveButton({Key? key}) : super(key: key);

  @override
  _RemoveButtonState createState() => _RemoveButtonState();
}

class _RemoveButtonState extends State<RemoveButton> {
  bool _loading = false;

  void _leave() async {
    setState(() {
      _loading = true;
    });
    final model = Provider.of<CurrentStatusViewModel>(context, listen: false);
    final message = model.currentStatus?.message;
    serviceLocator<AnalyticsService>().logRemoveCurrentStatus(message: message!);
    await model.removeStatus();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String buttonLabel = 'Remove';
    VoidCallback? onPressed = _loading ? null : () => _leave();

    return RoundedButton( buttonLabel: buttonLabel, onPressed: onPressed, loading: _loading, );
  }
}

class SuggestionSwipeStack extends StatefulWidget {
  const SuggestionSwipeStack({Key? key}) : super(key: key);

  @override
  _SuggestionSwipeStackState createState() => _SuggestionSwipeStackState();
}

class _SuggestionSwipeStackState extends State<SuggestionSwipeStack> {
  final List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine _matchEngine = MatchEngine(swipeItems: <SwipeItem>[]);

  @override
  void initState() {
    _load();
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    super.initState();
  }

  List<SwipeItem> _load() {
    final suggestionsModel = serviceLocator<SuggestionsViewModel>();
    for (int i = 0; i < suggestionsModel.suggestionsList.length; i++) {
      _swipeItems.add(SwipeItem(
          content: suggestionsModel.suggestionsList[i].message,
          likeAction: () {
            print('Liked ${suggestionsModel.suggestionsList[i].message}');
          },
          nopeAction: () {
            print('Nope ${suggestionsModel.suggestionsList[i].message}');
          },
          superlikeAction: () {
            print('SuperLike ${suggestionsModel.suggestionsList[i].message}');
          }));
    }

    // _matchEngine = MatchEngine(swipeItems: _swipeItems);

    return _swipeItems;
  }

  @override
  Widget build(BuildContext context) {
    return  SwipeCards(
      matchEngine: _matchEngine,
      itemBuilder: (BuildContext context, int index) {
        return SuggestionSwipeCard(message: _swipeItems[index].content);
      },
      onStackFinished: () {
        print('Stack Finished');
      },
    );
  }
}


class SuggestionSwipeCard extends StatelessWidget {
  final HwMessage message;
  const SuggestionSwipeCard({Key? key, required this.message}) : super(key: key);

  void _pushCreate(BuildContext context) async {
    serviceLocator<AnalyticsService>().logCurrentScreen(screenName: 'Add Status Page');
    Navigator.of(context).push(
      MaterialPageRoute<int>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return AddStatusPage(message: message,);
        },
        settings: RouteSettings(name: 'AddStatusPage'),
      ),
    );
  }

  void _send(BuildContext context) {
    final model = Provider.of<CurrentStatusViewModel>(context, listen: false);
    model.addStatus(message.id, message.content);
    final snackBar = SnackBar(content: Text('Updated Status \'${model.currentStatus?.message?.content}\''));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    serviceLocator<AnalyticsService>().logSendSuggestedToAll(message: model.currentStatus!.message!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => _send(context),
      onTap: () => _pushCreate(context),
      child: Card(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            message.content,
                            style: Styles.pageHeader,
                          ),
                        ),
                      ),
                    ),
                    Text('Double Tap to Send. Tap to Edit.', style: Styles.tipLightGrey,),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       likedBy,
                    //       style: Styles.headerGrey18,
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}








