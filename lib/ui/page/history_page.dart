import 'package:hamuwemu/business_logic/model/event_history_page_item.dart';
import 'package:hamuwemu/business_logic/view_model/active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/event_history_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/styles.dart';
import 'package:hamuwemu/ui/widget/error_message.dart';
import 'package:flutter/material.dart';
import 'package:hamuwemu/ui/widget/rounded_button.dart';
import 'package:hamuwemu/ui/widget/update_card.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                child: ChangeNotifierProvider<EventHistoryViewModel>(
                  create: (_) => EventHistoryViewModel(),
                  child: InfiniteHistoryList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfiniteHistoryList extends StatefulWidget {
  const InfiniteHistoryList({Key? key}) : super(key: key);

  @override
  _InfiniteHistoryListState createState() => _InfiniteHistoryListState();
}

class _InfiniteHistoryListState extends State<InfiniteHistoryList> {
  late final EventHistoryViewModel _model;
  final _pagingController = PagingController<String?, EventHistoryPageItem>(
    firstPageKey: null,
  );

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    _model = Provider.of<EventHistoryViewModel>(context, listen: false);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(userModel.user!.userId!, pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int userId, String? pageKey) async {
    print('Fetching page $pageKey');
    try {
      final newPage = await _model.loadNext(userId, pageKey);

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
            () {
              _pagingController.refresh();
              activeModel.loadEvent();
            },
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Now',
                      style: Styles.headerGrey36,
                    ),
                  ),
                  UpdateCard(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
                    child: Text('Before',
                      style: Styles.headerGrey36,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PagedSliverList.separated(
            pagingController: _pagingController,
            // padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) => SizedBox(
              height:  16.0,
            ),
            builderDelegate: PagedChildBuilderDelegate<EventHistoryPageItem>(
              itemBuilder:(context, pageItem, index) => EventHistoryListItem(
                pagingController: _pagingController,
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
        ],
      ),
    );
  }
}

class EventHistoryListItem extends StatelessWidget {
  final EventHistoryPageItem pageItem;
  final PagingController pagingController;

  EventHistoryListItem({Key? key, required this.pagingController, required this.pageItem}) : super(key: key);

  void _joinEvent(BuildContext context) async {
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    final model = Provider.of<ActiveEventViewModel>(context, listen: false);
    await model.joinEvent(userModel.user!.userId!, pageItem.description);
    pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    // final event = pageItem.event;
    final createdDt = DateTime.parse(pageItem.endTime);
    final createdTimeAgo = timeago.format(createdDt);
    //
    // String title = '${event.activity.characters.first.toLowerCase()}${event.activity.substring(1)}';

    String title =  pageItem.description ?? 'No Event';
    String buttonLabel =  'Join';
    VoidCallback? onPressed = () => _joinEvent(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RoundedButton(
                  buttonLabel: buttonLabel,
                  onPressed: onPressed,
                  loading: false,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: Container(
              padding: EdgeInsets.fromLTRB( 20.0 , 20.0, 20.0, 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Styles.headerBlack36,),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(createdTimeAgo, style: Styles.headerGrey18,),
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


