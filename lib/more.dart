import 'package:first_app/about.dart';
import 'package:first_app/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:list_tile_switch/list_tile_switch.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  bool swichValue = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: Column(
        children: [
          Align(
            child: Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Image.asset("assets/icons8-comic-book-96.png")),
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
            title: Text('Settings'),
            leading: Icon(Icons.settings_outlined, color: Colors.blue[400]),
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return const Settings();
                },
              ));
            },
          ),
          ListTile(
            title: Text('About'),
            leading: Icon(Icons.info_outline, color: Colors.blue[400]),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: ((context) => AboutScreen())));
            },
          )
        ],
      ),
    );
  }
}
