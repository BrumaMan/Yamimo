import 'package:first_app/settings_pages/advanced_pages/advanced_settings.dart';
import 'package:first_app/settings_pages/appearance_pages/apearance_settings.dart';
import 'package:first_app/settings_pages/general_pages/general_settings.dart';
import 'package:first_app/settings_pages/library_pages/library_settings.dart';
import 'package:first_app/settings_pages/reader_pages/reader_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_animation_transition/animations/fade_animation_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

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
              Navigator.of(context).push(PageAnimationTransition(
                  page: GeneralSettings(),
                  pageAnimationType: FadeAnimationTransition()));
            },
          ),
          ListTile(
            title: Text("Appearance"),
            leading: Icon(Icons.palette_outlined, color: Colors.blue),
            onTap: () => Navigator.of(context).push(PageAnimationTransition(
                page: AppearanceSettings(),
                pageAnimationType: FadeAnimationTransition())),
          ),
          ListTile(
            title: Text("Library"),
            leading:
                Icon(Icons.collections_bookmark_outlined, color: Colors.blue),
            onTap: () => Navigator.of(context).push(PageAnimationTransition(
                page: LibrarySettings(),
                pageAnimationType: FadeAnimationTransition())),
          ),
          ListTile(
            title: Text("Reader"),
            leading:
                Icon(Icons.chrome_reader_mode_outlined, color: Colors.blue),
            onTap: () {
              Navigator.of(context).push(PageAnimationTransition(
                  page: ReaderSettings(),
                  pageAnimationType: FadeAnimationTransition()));
            },
          ),
          ListTile(
            title: Text("Advanced"),
            leading: Icon(Icons.data_object, color: Colors.blue),
            onTap: () {
              Navigator.of(context).push(PageAnimationTransition(
                  page: AdvancedSettings(),
                  pageAnimationType: FadeAnimationTransition()));
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
