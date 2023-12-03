import 'package:flutter/foundation.dart';
import 'package:hamuwemu/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RoundedButton extends StatelessWidget {
  final String buttonLabel;
  final VoidCallback? onPressed;
  final bool loading;

  RoundedButton({Key? key, required this.buttonLabel, required this.onPressed, required this.loading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    //   constraints: const BoxConstraints(
    //       maxWidth: 500
    //   ),
    //   child: ElevatedButton(
    //     style: ButtonStyle(
    //       padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 12.0)),
    //       shape: MaterialStateProperty.resolveWith<OutlinedBorder>((_) {
    //         // return RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    //         return const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14)));
    //       }),
    //       side: MaterialStateProperty.resolveWith((states) {
    //         Color _borderColor;
    //
    //         if (states.contains(MaterialState.disabled)) {
    //           _borderColor = Colors.grey;
    //         } else if (states.contains(MaterialState.pressed)) {
    //           _borderColor = Colors.transparent;
    //         } else {
    //           _borderColor = Colors.black;
    //         }
    //
    //         return BorderSide(color: _borderColor, width: 1);
    //       }),
    //       foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
    //         if (states.contains(MaterialState.pressed)) {
    //           return Colors.white;
    //         } else if (states.contains(MaterialState.disabled)) {
    //           return Colors.grey;
    //         }
    //         return Colors.black;
    //       }),
    //       backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
    //         if (states.contains(MaterialState.pressed)) {
    //           return Colors.black;
    //         }
    //         return  MyColors.primaryColor;
    //       }),
    //     ),
    //     onPressed: loading ? null : onPressed,
    //     child: Container(
    //         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: <Widget>[
    //             Text(
    //               'Next',
    //               style: TextStyle(color: Colors.white),
    //             ),
    //             Container(
    //               padding: const EdgeInsets.all(8),
    //               decoration: BoxDecoration(
    //                 borderRadius: const BorderRadius.all(Radius.circular(20)),
    //                 color: MyColors.primaryColorLight,
    //               ),
    //               child: Icon(
    //                 Icons.arrow_forward_ios,
    //                 color: Colors.white,
    //                 size: 16,
    //               ),
    //             )
    //           ],
    //         ),
    //   ),
    //   ),
    // );

    return OutlinedButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric( vertical: 12.0, horizontal: 12.0)),
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>((_) {
          return RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
        }),
        side: MaterialStateProperty.resolveWith((states) {
          Color _borderColor;

          if (states.contains(MaterialState.disabled)) {
            _borderColor = Colors.grey;
          } else if (states.contains(MaterialState.pressed)) {
            _borderColor = Colors.transparent;
          } else {
            _borderColor = Colors.black;
          }

          return BorderSide(color: _borderColor, width: 1);
        }),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.white;
          } else if (states.contains(MaterialState.disabled)) {
            return Colors.grey;
          }
          return Colors.black;
        }),
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.black;
          }
          return Colors.transparent;
        }),
      ),
      onPressed: loading ? null : onPressed,
      child: loading ? Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                backgroundColor: Colors.transparent,
              )),
          SizedBox(
            width: 8,
          ),
          Text(buttonLabel, style: Styles.listTitleSemiBold,),
        ],
      ) :
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(buttonLabel, style: Styles.listTitleSemiBold,),
        ],
      ),
    );
  }
}

class RoundedAsyncButton extends StatefulWidget {
  final AsyncCallback? onPressed;
  final String buttonLabel;
  RoundedAsyncButton({Key? key, required this.onPressed, required this.buttonLabel}) : super(key: key);

  @override
  _RoundedAsyncButtonState createState() => _RoundedAsyncButtonState();
}

class _RoundedAsyncButtonState extends State<RoundedAsyncButton> {
  bool _loading = false;

  void _onPressed() async {
    setState(() {
      _loading = true;
    });

    await widget.onPressed?.call();

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RoundedButton(buttonLabel: widget.buttonLabel, onPressed: _loading ? null : _onPressed, loading: _loading);
  }
}

