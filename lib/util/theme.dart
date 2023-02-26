import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Box settingsBox = Hive.box("settings");

ThemeData lightTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
    toolbarTextStyle: TextStyle(color: Colors.white),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: Typography().white,
  scaffoldBackgroundColor: Colors.black,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  useMaterial3: true,
);
ThemeData darkTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
        color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
    toolbarTextStyle: TextStyle(color: Colors.black),
    iconTheme: IconThemeData(color: Colors.black),
  ),
  textTheme: Typography().black,
  scaffoldBackgroundColor: Colors.white,
  iconTheme: const IconThemeData(
    color: Colors.black,
  ),
  useMaterial3: true,
);

var black = Colors.black;
var white = Colors.white;

var iconColor =
    settingsBox.get("darkMode", defaultValue: false) ? white : black;
