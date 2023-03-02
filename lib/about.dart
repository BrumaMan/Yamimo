import 'package:auto_update/auto_update.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:auto_update/fetch_github.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:io';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? info = PackageInfo(
      appName: 'Mangalux',
      packageName: 'Mangalux',
      version: '0.1.0',
      buildNumber: '0.1.0');

  Map<dynamic, dynamic> _updateInfo = {};
  var version;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPackage();
    getUpdate();
  }

  Future<void> getPackage() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      info = packageInfo;
      List<String>? ver = info?.version.split('.');
      if (ver?[2] == '0') {
        version = '${ver?[0]}.${ver?[1]}';
      } else {
        version = info?.version;
      }
    });
  }

  Future<void> getUpdate() async {
    Map<dynamic, dynamic> results = await fetchGithub(
      "BrumaMan",
      "Yamimo",
      "application/vnd.android.package-archive",
      "v$version",
      "Yamimo-v${version}.apk",
    );

    setState(() {
      _updateInfo = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  Align(child: Image.asset("assets/icons8-comic-book-96.png")),
            ),
            Divider(
              color: Colors.grey[200],
            ),
            ListTile(
              title: Text('Version ${info?.version}'),
              subtitle: Text('Check for updates'),
              onTap: () async {
                debugPrint("$_updateInfo");
                Fluttertoast.showToast(
                    msg: 'Checking',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);
                if (_updateInfo != null) {
                  if (_updateInfo['tag'] == "v$version") {
                    /* aplication is up-to-date */
                    Fluttertoast.showToast(
                        msg: 'No new update',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        fontSize: 16.0);
                  } else if (_updateInfo['assetUrl'] == "") {
                    /* package or user don't found */
                    print("${_updateInfo}");
                    Fluttertoast.showToast(
                        msg: 'An error occured',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        fontSize: 16.0);
                  } else {
                    /* update url found */
                    debugPrint("${_updateInfo}");
                    Fluttertoast.showToast(
                        msg: 'New update available',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        fontSize: 16.0);
                    await AutoUpdate.downloadAndUpdate(_updateInfo['assetUrl']);
                  }
                }
              },
            ),
            ListTile(
              title: Text("What's new"),
              onTap: () async {
                AndroidIntent intent = AndroidIntent(
                  action: 'action_view',
                  package: 'com.github.android',
                  data:
                      'https://github.com/BrumaMan/Yamimo/releases/tag/v$version',
                );
                await intent.launch();
              },
            ),
            ListTile(
              title: Text("Open source licenses"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: ((context) => LicensePage(
                          applicationName: '${info?.appName}',
                          applicationVersion: '${info?.version}',
                        ))));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.public_outlined,
                  color: Colors.blue[400],
                ),
                GestureDetector(
                  child: LineIcon.twitter(color: Colors.blue[400]),
                  onTap: () async {
                    AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      package: 'com.twitter.android',
                      data: 'https://twitter.com/BartoszMazu',
                    );
                    await intent.launch();
                  },
                ),
                GestureDetector(
                  child: LineIcon.github(color: Colors.blue[400]),
                  onTap: () async {
                    AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      package: 'com.github.android',
                      data: 'https://github.com/BrumaMan/Yamimo',
                    );
                    await intent.launch();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
