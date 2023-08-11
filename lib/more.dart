import 'package:first_app/about.dart';
import 'package:first_app/overview.dart';
import 'package:first_app/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:page_animation_transition/animations/fade_animation_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  bool swichValue = false;
  Box settingsBox = Hive.box('settings');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: settingsBox.listenable(),
            builder: (context, value, child) => Align(
              child: Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: settingsBox.get('darkMode', defaultValue: false)
                      ? Image.asset("assets/Yamimo_ic_256_dark.png",
                          width: 96.0, height: 96.0)
                      : Image.asset("assets/Yamimo_ic_256_light.png",
                          width: 96.0, height: 96.0)),
            ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 0.7,
          ),
          // ListTileSwitch(
          //   value: swichValue,
          //   title: Text('Downloaded only'),
          //   subtitle: Text('Filters all manga in your library'),
          //   leading: Icon(Icons.cloud_off_outlined, color: Colors.blue[400]),
          //   switchInactiveColor: Colors.grey[700],
          //   onChanged: ((value) {
          //     setState(() {
          //       swichValue = !swichValue;
          //     });
          //   }),
          // ),
          // ListTileSwitch(
          //   value: swichValue,
          //   title: Text('Incognito mode'),
          //   subtitle: Text('Pauses reading history'),
          //   leading: Icon(Icons.security_outlined, color: Colors.blue[400]),
          //   switchInactiveColor: Colors.grey[700],
          //   onChanged: (value) {
          //     setState(() {
          //       swichValue = !swichValue;
          //     });
          //   },
          // ),
          // Divider(
          //   color: Colors.grey,
          //   thickness: 0.7,
          // ),
          ListTile(
            title: Text('Overview'),
            leading: Icon(Icons.bar_chart,
                color: Theme.of(context).colorScheme.primary),
            onTap: () {
              Navigator.of(context).push(PageAnimationTransition(
                  page: Overview(),
                  pageAnimationType: FadeAnimationTransition()));
            },
          ),
          ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings_outlined,
                color: Theme.of(context).colorScheme.primary),
            onTap: () {
              Navigator.of(context).push(PageAnimationTransition(
                  page: const Settings(),
                  pageAnimationType: FadeAnimationTransition()));
            },
          ),
          ListTile(
            title: Text('About'),
            leading: Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.primary),
            onTap: () {
              Navigator.of(context).push(PageAnimationTransition(
                  page: const AboutScreen(),
                  pageAnimationType: FadeAnimationTransition()));
            },
          )
        ],
      ),
    );
  }
}
