import 'package:flutter/material.dart';
import 'package:hamuwemu/business_logic/view_model/current_status_view_model.dart';
import 'package:provider/provider.dart';

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