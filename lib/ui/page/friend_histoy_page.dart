import 'package:hamuwemu/business_logic/model/event_history_page_item.dart';
import 'package:hamuwemu/business_logic/model/status_history_page_item.dart';
import 'package:hamuwemu/business_logic/view_model/active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/event_history_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/history_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/styles.dart';
import 'package:hamuwemu/ui/widget/add_button.dart';
import 'package:hamuwemu/ui/widget/error_message.dart';
import 'package:flutter/material.dart';
import 'package:hamuwemu/ui/widget/rounded_button.dart';
import 'package:hamuwemu/ui/widget/update_card.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendHistoryPage extends StatelessWidget {
  final String name;
  final String status;
  final int historyUserId;
  const FriendHistoryPage({Key? key, required this.historyUserId, required this.name, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back,color: Colors.black,),
                  ),
                  SizedBox(width: 2,),
                  CircleAvatar(
                    backgroundColor: Colors.brown.shade800,
                    child: Text(name.characters.first.toUpperCase()),
                  ),
                  SizedBox(width: 12,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(name,style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                        SizedBox(height: 6,),
                        Text(status,style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
                      ],
                    ),
                  ),
                  Icon(Icons.settings,color: Colors.black54,),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ChangeNotifierProvider<HistoryViewModel>(
                  create: (_) => HistoryViewModel(),
                  child: HistoryList(historyUserId: historyUserId,),
                ),
              ),
            ],
          ),
        ),
    );

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'History',
                      style: Styles.headerBlack36,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ChangeNotifierProvider<HistoryViewModel>(
                  create: (_) => HistoryViewModel(),
                  child: HistoryList(historyUserId: historyUserId,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class HistoryList extends StatefulWidget {
  final int historyUserId;
  const HistoryList({Key? key, required this.historyUserId}) : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  late final HistoryViewModel _model;
  final _pagingController = PagingController<String?, StatusHistoryPageItem>(
    firstPageKey: null,
  );

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    _model = Provider.of<HistoryViewModel>(context, listen: false);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(String? pageKey) async {
    print('Fetching page $pageKey');
    try {
      final newPage = await _model.loadNext(widget.historyUserId, pageKey);

      final isLastPage = newPage.nextPageKey == null;
      final newItems = newPage.itemList;

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newPage.nextPageKey;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error, s) {
      print(s);
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    final activeModel = Provider.of<ActiveEventViewModel>(context, listen: false);

    return RefreshIndicator(
      onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
      ),
      child: PagedListView.separated(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => SizedBox(
          height:  16.0,
        ),
          builderDelegate: PagedChildBuilderDelegate<StatusHistoryPageItem>(
            itemBuilder:(context, pageItem, index) => HistoryListItemCard(
                pageItem: pageItem
            ),
            firstPageErrorIndicatorBuilder: (context) => ErrorMessage(
              message:_pagingController.error.toString(),
            ),
            noItemsFoundIndicatorBuilder: (context) => Column(
              children: [
                Center(
                  child: Text('No Past Events'),
                ),
              ],
            ),
          ),

      ),
    );
  }
}

class HistoryListItemCard extends StatelessWidget {
  final StatusHistoryPageItem pageItem;
  const HistoryListItemCard({Key? key, required this.pageItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String description =  pageItem.message.content;

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
                  messageId: pageItem.message.id,
                  messageContent: pageItem.message.content,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
