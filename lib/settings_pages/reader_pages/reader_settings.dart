import 'package:flutter/material.dart';
import 'package:list_tile_switch/list_tile_switch.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ReaderSettings extends StatefulWidget {
  const ReaderSettings({super.key});

  @override
  State<ReaderSettings> createState() => _ReaderSettingsState();
}

class _ReaderSettingsState extends State<ReaderSettings> {
  Box settingsBox = Hive.box('settings');
  late bool showReaderMode;
  late String? readerBgColor;
  late bool keepScreenOn;
  late bool showPageNumber;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showReaderMode = settingsBox.get('showReaderMode', defaultValue: true);
    readerBgColor = settingsBox.get('readerBgColor', defaultValue: 'Black');
    keepScreenOn = settingsBox.get('keepScreenOn', defaultValue: true);
    showPageNumber = settingsBox.get('showPageNumber', defaultValue: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reader'),
      ),
      body: Column(
        children: [
          SwitchListTile(
              title: Text('Show reading mode'),
              subtitle: Text('Briefly show current mode when reader is opened'),
              value: showReaderMode,
              onChanged: (value) {
                setState(() {
                  showReaderMode = value;
                });
                settingsBox.put('showReaderMode', value);
              }),
          ListTile(
            title: Text('Reader background color'),
            subtitle: Text('$readerBgColor'),
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
                              title: Text('Black'),
                              value: 'Black',
                              groupValue: readerBgColor,
                              onChanged: (value) => setState(() {
                                    readerBgColor = value;
                                    settingsBox.put(
                                        'readerBgColor', readerBgColor);
                                    Navigator.pop(context);
                                  })),
                          RadioListTile(
                              title: Text('Gray'),
                              value: 'Gray',
                              groupValue: readerBgColor,
                              onChanged: (value) => setState(() {
                                    readerBgColor = value;
                                    settingsBox.put(
                                        'readerBgColor', readerBgColor);
                                    Navigator.pop(context);
                                  })),
                          RadioListTile(
                              title: Text('White'),
                              value: 'White',
                              groupValue: readerBgColor,
                              onChanged: (value) => setState(() {
                                    readerBgColor = value;
                                    settingsBox.put(
                                        'readerBgColor', readerBgColor);
                                    Navigator.pop(context);
                                  })),
                        ],
                      ),
                    );
                  });
            },
          ),
          SwitchListTile(
              title: Text('Keep screen on'),
              subtitle: Text('Keep screen awake when in reader'),
              value: keepScreenOn,
              onChanged: (value) {
                setState(() {
                  keepScreenOn = value;
                });
                settingsBox.put('keepScreenOn', value);
              }),
          SwitchListTile(
              title: Text('Show page number'),
              subtitle: Text('Show current page number on the bottom'),
              value: showPageNumber,
              onChanged: (value) {
                setState(() {
                  showPageNumber = value;
                });
                settingsBox.put('showPageNumber', value);
              }),
        ],
      ),
    );
  }
}
