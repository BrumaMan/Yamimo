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
  chipTheme: ChipThemeData(
      backgroundColor: Colors.black,
      labelStyle: TextStyle(color: Colors.white)),
  colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromARGB(255, 65, 22, 184), brightness: Brightness.dark),
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
  chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: Colors.black)),
  colorScheme:
      ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 65, 22, 184)),
  useMaterial3: true,
);

var black = Colors.black;
var white = Colors.white;

var iconColor =
    settingsBox.get("darkMode", defaultValue: false) ? white : black;
