import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

List<String> sources = [
  'MangaDex',
  'Comick',
];

final ScrollController homeScrollController = ScrollController();
