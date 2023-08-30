import 'package:first_app/settings_pages/advanced_pages/advanced_settings.dart';
import 'package:first_app/settings_pages/appearance_pages/apearance_settings.dart';
import 'package:first_app/settings_pages/general_pages/general_settings.dart';
import 'package:first_app/settings_pages/library_pages/library_settings.dart';
import 'package:first_app/settings_pages/reader_pages/reader_settings.dart';
import 'package:first_app/util/page_animation_wrapper.dart';
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
            leading:
                Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
            onTap: () {
              Navigator.of(context).push(PageAnimationWrapper(
                key: ValueKey('General'),
                screen: GeneralSettings(),
              ));
            },
          ),
          ListTile(
            title: Text("Appearance"),
            leading: Icon(Icons.palette_outlined,
                color: Theme.of(context).colorScheme.primary),
            onTap: () => Navigator.of(context).push(PageAnimationWrapper(
              key: ValueKey('Appearance'),
              screen: AppearanceSettings(),
            )),
          ),
          ListTile(
            title: Text("Library"),
            leading: Icon(Icons.collections_bookmark_outlined,
                color: Theme.of(context).colorScheme.primary),
            onTap: () => Navigator.of(context).push(PageAnimationWrapper(
              key: ValueKey('Library'),
              screen: LibrarySettings(),
            )),
          ),
          ListTile(
            title: Text("Reader"),
            leading: Icon(Icons.chrome_reader_mode_outlined,
                color: Theme.of(context).colorScheme.primary),
            onTap: () {
              Navigator.of(context).push(PageAnimationWrapper(
                key: ValueKey('Reader'),
                screen: ReaderSettings(),
              ));
            },
          ),
          ListTile(
            title: Text("Advanced"),
            leading: Icon(Icons.data_object,
                color: Theme.of(context).colorScheme.primary),
            onTap: () {
              Navigator.of(context).push(PageAnimationWrapper(
                key: ValueKey('Advanced'),
                screen: AdvancedSettings(),
              ));
            },
          ),
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
