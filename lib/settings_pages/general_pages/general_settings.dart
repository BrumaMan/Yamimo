import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  Box settingsBox = Hive.box('settings');
  late String? startScreen;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startScreen = settingsBox.get('startScreen', defaultValue: 'Library');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('General'),
        ),
        body: Column(
          children: [
            ListTile(
                title: Text('Start screen'),
                subtitle: Text('$startScreen'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Start screen'),
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
                                  title: Text('Library'),
                                  value: 'Library',
                                  groupValue: startScreen,
                                  onChanged: (value) => setState(() {
                                        startScreen = value;
                                        settingsBox.put(
                                            'startScreen', startScreen);
                                        Navigator.pop(context);
                                      })),
                              RadioListTile(
                                  title: Text('Explore'),
                                  value: 'Explore',
                                  groupValue: startScreen,
                                  onChanged: (value) => setState(() {
                                        startScreen = value;
                                        settingsBox.put(
                                            'startScreen', startScreen);
                                        Navigator.pop(context);
                                      })),
                              // RadioListTile(
                              //     title: Text('3 Items'),
                              //     value: 3,
                              //     groupValue: startScreen,
                              //     onChanged: (value) => setState(() {
                              //           startScreen = value;
                              //           settingsBox.put('rowItems', startScreen);
                              //           Navigator.pop(context);
                              //         })),
                            ],
                          ),
                        );
                      });
                })
          ],
        ));
  }
}
