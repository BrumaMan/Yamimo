import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppearanceSettings extends StatefulWidget {
  const AppearanceSettings({super.key});

  @override
  State<AppearanceSettings> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends State<AppearanceSettings> {
  Box settingsBox = Hive.box("settings");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Appearance")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Dark Mode"),
                Switch(
                    value: settingsBox.get("darkMode", defaultValue: false),
                    onChanged: (value) => setState(() {
                          settingsBox.put("darkMode", value);
                        })),
              ],
            )
          ],
        ),
      ),
    );
  }
}
