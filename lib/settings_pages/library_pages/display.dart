import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:list_tile_switch/list_tile_switch.dart';

class Display extends StatefulWidget {
  const Display({super.key, required this.context});

  final BuildContext context;

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  Box settingsBox = Hive.box('settings');

  late int? checkValue;
  bool switchValue = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkValue = settingsBox.get('rowItems', defaultValue: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Display', style: TextStyle(color: Colors.blue)),
            ListTile(
              title: Text('Items per row'),
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              onTap: () {
                showDialog(
                    context: context,
                    builder: ((context) {
                      return AlertDialog(
                        title: Text('Items per row'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel')),
                          // TextButton(onPressed: () {}, child: Text('Ok')),
                        ],
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile(
                                title: Text('1 Item'),
                                value: 1,
                                groupValue: checkValue,
                                onChanged: (value) => setState(() {
                                      checkValue = value;
                                      settingsBox.put('rowItems', checkValue);
                                      Navigator.pop(context);
                                    })),
                            RadioListTile(
                                title: Text('Default (2)'),
                                value: 2,
                                groupValue: checkValue,
                                onChanged: (value) => setState(() {
                                      checkValue = value;
                                      settingsBox.put('rowItems', checkValue);
                                      Navigator.pop(context);
                                    })),
                            RadioListTile(
                                title: Text('3 Items'),
                                value: 3,
                                groupValue: checkValue,
                                onChanged: (value) => setState(() {
                                      checkValue = value;
                                      settingsBox.put('rowItems', checkValue);
                                      Navigator.pop(context);
                                    })),
                          ],
                        ),
                      );
                    }));
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              title: Text('Jump to chapters on open'),
              value: switchValue,
              onChanged: (value) => setState(() {
                switchValue = value;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
