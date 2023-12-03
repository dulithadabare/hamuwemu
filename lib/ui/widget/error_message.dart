import 'package:empty_widget/empty_widget.dart';
import 'package:hamuwemu/styles.dart';
import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  ErrorMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: EmptyWidget(
          image: null,
          packageImage: PackageImage.Image_1,
          title: 'Oops',
          subTitle: 'Something went wrong',
          titleTextStyle: TextStyle(
            fontSize: 22,
            color: Color(0xff9da9c7),
            fontWeight: FontWeight.w500,
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 14,
            color: Color(0xffabb8d6),
          ),
          hideBackgroundAnimation: true,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onPressed;

  EmptyState({Key? key, required this.title, required this.subtitle, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            EmptyWidget(
              image: null,
              packageImage: PackageImage.Image_1,
              title: title,
              subTitle: subtitle,
              titleTextStyle: TextStyle(
                fontSize: 22,
                color: Color(0xff9da9c7),
                fontWeight: FontWeight.w500,
              ),
              subtitleTextStyle: TextStyle(
                fontSize: 14,
                color: Color(0xffabb8d6),
              ),
              hideBackgroundAnimation: true,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onPressed,
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
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  ErrorState({Key? key, required this.title, required this.subtitle, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: EmptyWidget(
          image: null,
          packageImage: PackageImage.Image_1,
          title: title,
          subTitle: subtitle,
          titleTextStyle: TextStyle(
            fontSize: 22,
            color: Color(0xff9da9c7),
            fontWeight: FontWeight.w500,
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 14,
            color: Color(0xffabb8d6),
          ),
          hideBackgroundAnimation: true,
        ),
      ),
    );
  }
}


