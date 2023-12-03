import 'package:hamuwemu/business_logic/model/hw_message.dart';
import 'package:hamuwemu/business_logic/model/suggested_status.dart';
import 'package:hamuwemu/business_logic/view_model/abstract_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/add_status_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/current_status_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/suggestions_view_model.dart';
import 'package:hamuwemu/service/analytics_service.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/styles.dart';
import 'package:hamuwemu/ui/widget/loading_large.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddStatusPage extends StatefulWidget {
  final HwMessage message;

  const AddStatusPage({Key? key, required this.message}) : super(key: key);

  @override
  _AddStatusPageState createState() => _AddStatusPageState();
}

class _AddStatusPageState extends State<AddStatusPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  AnalyticsService get analytics => serviceLocator<AnalyticsService>();

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _next(AddStatusViewModel model) {
    _tabController.animateTo(1);
    model.enabled = true;
  }

  void _createConfirmedEvent( BuildContext context, AddStatusViewModel model ) async {
    // final response = await model.addStatus();

    final statusModel = Provider.of<CurrentStatusViewModel>(context, listen: false);
    statusModel.addStatus(0, model.description);
    final snackBar = SnackBar(content: Text('Updated Status \'${statusModel.currentStatus?.message?.content}\''));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // serviceLocator<AnalyticsService>().logAddNewStatus(message: statusModel.currentStatus!.message!);
    Navigator.of(context).pop(-1);

    // if( response.status == ApiResponseStatus.COMPLETED ) {
    //   final statusModel = Provider.of<CurrentStatusViewModel>(context, listen: false);
    //   await statusModel.loadEvent();
    //   await analytics.logAddNewStatus(message: statusModel.currentStatus!.message!);
    //   final snackBar = SnackBar(content: Text('Sent Event!'));
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //   Navigator.of(context).pop(-1);
    // } else  if( response.status == ApiResponseStatus.ERROR ) {
    //   final snackBar = SnackBar(content: Text('Sending Event Failed!'));
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //   Navigator.of(context).pop(-1);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddStatusViewModel>(
      create: (_) => AddStatusViewModel(),
      child: Consumer<AddStatusViewModel>(
          builder: (context, model, child) {
            return Scaffold(
              appBar: AppBar(
                leading: CloseButton(
                  color: Colors.black,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                actions: [
                  TextButton(
                      onPressed: model.enabled ? () => _createConfirmedEvent(context, model) : null,
                      child: Text('Send',
                        style: model.enabled ? TextStyle(color: Colors.black,) : TextStyle(color: Colors.grey,),
                      )
                  ),
                ],
              ),
              body: AddEventTab( message: widget.message,),
            );
          }
      ),
    );
  }
}

class AddEventTab extends StatefulWidget {
  final HwMessage message;

  const AddEventTab({Key? key,required this.message}) : super(key: key);

  @override
  _AddEventTabState createState() => _AddEventTabState();
}

class _AddEventTabState extends State<AddEventTab> {
  TextEditingController _nounController = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    final model = Provider.of<AddStatusViewModel>(context, listen: false);
    // _nounController.text = serviceLocator<SuggestionsViewModel>().suggestedStatus.content;
    _nounController.text = widget.message.content;
    _charCount = widget.message.content.characters.length;
    _nounController.addListener(() => setEvent(model));
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _nounController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _setText(String text) {
    _nounController.text = text;
  }

  void setEvent( AddStatusViewModel model ) {
    bool valid = true;
    final value = _nounController.text;
    model.description = value;
    _charCount = value.characters.length;

    if( value.characters.isEmpty ) {
      valid = false;
    }

    if( !valid ) {
      model.enabled = false;
    } else {
      model.enabled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<CurrentStatusViewModel>(context);
    String description =  '';
    TextStyle? titleTextStyle = Styles.headerLightGrey36;
    String createdTimeAgo = '';
    String likedBy = '';
    bool noEvent = true;
    if(model.status != ViewModelStatus.busy && model.currentStatus != null) {
      description = model.currentStatus?.message?.content ?? 'No Status';
      if(model.currentStatus?.message?.content != null ) {
        titleTextStyle = Styles.headerBlack36;
        noEvent = false;
      }

      // if(model.activeEvent!.event.likedUserList.isNotEmpty) {
      //   likedBy = 'Liked by ${model.activeEvent!.event.likedUserList.first.displayName}';
      // }
    }
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Add Status",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
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
                          '$_charCount/140',
                          style: Styles.headerGrey18,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _nounController,
                            maxLines: null,
                            autofocus: true,
                            expands: true,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(140),
                              FilteringTextInputFormatter.singleLineFormatter,
                            ],
                            style: Styles.headerBlack36,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Type here...',
                              hintStyle: Styles.headerLightGrey36,
                            ),
                            textInputAction: TextInputAction.done,
                            enableInteractiveSelection: true,
                          ),
                        ),
                      ),
                    ),
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
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text('Suggested', style: Styles.headerLightGrey36,),
          // ),
          // Expanded(
          //   child: StatusSuggestionsList(
          //     setText: _setText,
          //   ),
          // ),
          // Expanded(
          //   child: TextField(
          //     controller: _nounController,
          //     maxLines: null,
          //     autofocus: true,
          //     expands: true,
          //     inputFormatters: [
          //       LengthLimitingTextInputFormatter(140),
          //       FilteringTextInputFormatter.singleLineFormatter,
          //     ],
          //     style: Styles.headerBlack36,
          //     decoration: InputDecoration(
          //       border: InputBorder.none,
          //       hintText: 'Type here...',
          //       hintStyle: Styles.headerLightGrey36,
          //     ),
          //     textInputAction: TextInputAction.done,
          //     enableInteractiveSelection: true,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class StatusSuggestionsList extends StatelessWidget {
  final void Function(String text) setText;
  const StatusSuggestionsList({Key? key, required this.setText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<SuggestionsViewModel>(context);
    final tiles = model.suggestionsList.map(
          (SuggestedStatus feedItem) {
        return GestureDetector(
          onTap: () => setText(feedItem.message.content),
            child: SuggestionCard(
                suggestedStatus: feedItem,
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


class SuggestionCard extends StatelessWidget {
  final SuggestedStatus suggestedStatus;
  const SuggestionCard({Key? key, required this.suggestedStatus}) : super(key: key);

  void _add(BuildContext context) async {
    final model = Provider.of<CurrentStatusViewModel>(context, listen: false);
    model.addStatus(suggestedStatus.message.id, suggestedStatus.message.content);
    final snackBar = SnackBar(content: Text('Updated Status \'${model.currentStatus?.message?.content}\''));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String description =  suggestedStatus.message.content;
    TextStyle? titleTextStyle = Styles.headerLightGrey36;

    final createdDt = DateTime.fromMillisecondsSinceEpoch(suggestedStatus.lastSentTime);

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
                  style: Styles.listTitle,
                ),
                IconButton(
                    onPressed: () => _add(context),
                    color: Colors.black,
                    icon: Icon(Icons.add)),
                // AddButton(
                //   messageId: suggestedStatus.message.id,
                //   messageContent: suggestedStatus.message.content,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddButton extends StatefulWidget {
  final int? messageId;
  final String? messageContent;
  const AddButton({Key? key, this.messageId, this.messageContent}) : super(key: key);

  @override
  _AddButtonState createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  bool _loading = false;

  void _leave() async {
    setState(() {
      _loading = true;
    });
    final model = Provider.of<CurrentStatusViewModel>(context, listen: false);
    model.addStatus(widget.messageId, widget.messageContent!);
    final snackBar = SnackBar(content: Text('Updated Status \'${model.currentStatus?.message?.content}\''));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {
      _loading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String buttonLabel = 'Add';
    VoidCallback? onPressed = _loading ? null : () => _leave();

    return InkWell(
      onTap: widget.messageContent != null ? onPressed : null,
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
    );

    // return RoundedButton( buttonLabel: buttonLabel, onPressed: onPressed, loading: _loading, );
  }
}




