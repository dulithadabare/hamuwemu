import 'package:hamuwemu/business_logic/model/response.dart';
import 'package:hamuwemu/business_logic/view_model/abstract_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/add_update_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/styles.dart';
import 'package:hamuwemu/ui/widget/error_message.dart';
import 'package:hamuwemu/ui/widget/loading_large.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddUpdatePage extends StatelessWidget {

  void _createEvent( BuildContext context ) async {
    final _userModel = Provider.of<UserViewModel>(context, listen: false);
    final _addUpdateModel = Provider.of<AddUpdateViewModel>(context, listen: false);
    final _activeEventModel = Provider.of<ActiveEventViewModel>(context, listen: false);

    final response = await _addUpdateModel.createEvent();

    if( response.status == ApiResponseStatus.COMPLETED ) {
      print('Post Created');
      final snackBar = SnackBar(content: Text('Sent Pop!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Navigator.of(context).pop(response.data!.event.id);
      _activeEventModel.loadEvent();
      Navigator.of(context).pop();
    } else  if( response.status == ApiResponseStatus.ERROR ) {
      final snackBar = SnackBar(content: Text('Update Failed!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.of(context).pop(-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddUpdateViewModel>(
      create: (_) => AddUpdateViewModel(),
      child: Consumer<AddUpdateViewModel>(
          builder: (context, model, child) {
            return Scaffold(
              appBar: AppBar(
                leading: CloseButton(
                  color: Colors.black,
                  onPressed: () => Navigator.of(context).pop(-1),
                ),
                title: Text('Add Update', style: TextStyle(
                    color: Colors.black
                ),),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                actions: [
                  TextButton(
                      onPressed: model.enabled ? () => _createEvent(context) : null,
                      child: Text('Send',
                        style: model.enabled ? TextStyle(color: Colors.black,) : TextStyle(color: Colors.grey,),
                      )
                  ),
                ],
              ),
              body: AddPop(),
            );
          }
      ),
    );
  }
}


class AddPop extends StatefulWidget {
  @override
  _AddPopState createState() => _AddPopState();
}

class _AddPopState extends State<AddPop> {
  TextEditingController _nounController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final model = Provider.of<AddUpdateViewModel>(context, listen: false);
    _nounController.addListener(() => setEvent(model));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _nounController.dispose();
    super.dispose();
  }

  void setEvent( AddUpdateViewModel model ) {
    bool valid = true;
    final value = _nounController.text;
    model.description = value;

    if( value.characters.isEmpty ) {
      valid = false;
    }

    if( !valid ) {
      model.enabled = false;
    } else {
      model.enabled = true;
    }
    // print(model.description);
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AddUpdateViewModel>(context);

    if(model.status == ViewModelStatus.busy) {
      return Center(
        child: LoadingLarge(),
      );
    } else if(model.status == ViewModelStatus.error) {
      return ErrorMessage(message: 'Could not send Pop');
    }

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _nounController,
              maxLines: null,
              autofocus: true,
              expands: true,
              inputFormatters: [
                LengthLimitingTextInputFormatter(140),
                FilteringTextInputFormatter.singleLineFormatter,
              ],
              style: Styles.headerBlack76,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'dinner today at 7pm in the Park',
                hintStyle: Styles.headerGrey,
              ),
              textInputAction: TextInputAction.done,
            ),
          ),
        ],
      ),
    );
  }
}

