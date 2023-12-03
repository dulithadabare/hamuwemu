import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyColors {
  static const Color primaryColor = Colors.red;
}

abstract class Styles {
  FontWeight _medium = FontWeight.w500;
  FontWeight _regular = FontWeight.normal;

  static const pageHeader = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold
  );

  static const listTitle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500
  );

  static const listTitleLightGrey = TextStyle(
      color: Color(0xFFE5E5E5),
      fontSize: 16,
      fontWeight: FontWeight.w500
  );

  static const listTitleSemiBold = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600
  );

  static const listSubtitle = TextStyle(
    color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold
  );

  static const listSubtitleLight = TextStyle(
      color: Colors.grey,
      fontSize: 14,
      fontWeight: FontWeight.normal
  );

  static const pageHeaderLightGrey = TextStyle(
      color: Color(0xFFE5E5E5),
      fontSize: 32,
      fontWeight: FontWeight.bold
  );

  static const tipLightGrey = TextStyle(
    color: Color(0xFFE5E5E5),
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
    fontSize: 12,
  );


  static const headerBlack76 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    fontSize: 72,
  );

  static const headerGrey = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    fontSize: 72,
  );

  static const headerBlack36 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    fontSize: 36,
  );

  static const headerGrey36 = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    fontSize: 36,
  );

  static const headerLightGrey36 = TextStyle(
    color: Color(0xFFE5E5E5),
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    fontSize: 36,
  );

  static const headerLightGrey18 = TextStyle(
    color: Color(0xFFE5E5E5),
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    fontSize: 18,
  );

  static const button18 = TextStyle(
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
    fontSize: 18,
  );

  static const bodyBlack18 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
    fontSize: 18,
  );

  static const bodyGrey18 = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
    fontSize: 18,
  );

  static const headerBlack18 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    fontSize: 18,
  );

  static const headerGrey18 = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    fontSize: 18,
  );
}