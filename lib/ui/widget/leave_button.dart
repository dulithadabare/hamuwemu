import 'package:hamuwemu/business_logic/view_model/active_event_view_model.dart';
import 'package:hamuwemu/ui/widget/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeaveButton extends StatefulWidget {
  const LeaveButton({Key? key}) : super(key: key);

  @override
  _LeaveButtonState createState() => _LeaveButtonState();
}

class _LeaveButtonState extends State<LeaveButton> {
  bool _loading = false;

  void _leave() async {
    final model = Provider.of<ActiveEventViewModel>(context, listen: false);
    setState(() {
      _loading = true;
    });
    await model.leaveEvent();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String buttonLabel = 'Leave';
    VoidCallback onPressed =  () => _leave();

    return RoundedButton( buttonLabel: buttonLabel, onPressed: onPressed, loading: _loading, );
  }
}
