import 'package:first_app/settings_pages/appearance_pages/apearance_settings.dart';
import 'package:first_app/settings_pages/general_pages/general_settings.dart';
import 'package:first_app/settings_pages/library_pages/library_settings.dart';
import 'package:first_app/settings_pages/reader_pages/reader_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text("General"),
            leading: Icon(Icons.tune, color: Colors.blue),
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: ((context) => GeneralSettings())));
            },
          ),
          ListTile(
            title: Text("Appearance"),
            leading: Icon(Icons.palette_outlined, color: Colors.blue),
            onTap: () => Navigator.of(context).push(CupertinoPageRoute(
                builder: ((context) => AppearanceSettings()))),
          ),
          ListTile(
            title: Text("Library"),
            leading:
                Icon(Icons.collections_bookmark_outlined, color: Colors.blue),
            onTap: () => Navigator.of(context).push(
                CupertinoPageRoute(builder: ((context) => LibrarySettings()))),
          ),
          ListTile(
            title: Text("Reader"),
            leading:
                Icon(Icons.chrome_reader_mode_outlined, color: Colors.blue),
            onTap: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: ((context) => ReaderSettings())));
            },
          ),
          // ListTile(
          //   title: Text("Downloads"),
          //   leading: Icon(Icons.download_outlined, color: Colors.blue),
          // ),
          // ListTile(
          //   title: Text("Tracking"),
          //   leading: Icon(Icons.sync_outlined, color: Colors.blue),
          // ),
          // ListTile(
          //   title: Text("Advanced"),
          //   leading: Icon(Icons.code_outlined, color: Colors.blue),
          // ),
        ],
      ),
    );
  }
}
