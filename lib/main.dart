// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:first_app/browse.dart';
import 'package:first_app/home.dart';
import 'package:first_app/more.dart';
import 'package:first_app/responsive/desktop_layout.dart';
import 'package:first_app/responsive/responsive_layout.dart';
import 'package:first_app/source/model/chapter.dart';
import 'package:first_app/source/model/manga_details.dart';
import 'package:first_app/update_screen.dart';
import 'package:first_app/util/globals.dart';
import 'package:first_app/util/page_animation_wrapper.dart';
import 'package:first_app/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bottom_bar_page_transition/bottom_bar_page_transition.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(MangaDetailsAdapter());
  Hive.registerAdapter(ChapterAdapter());

  var settings_Box = await Hive.openBox('settings');
  var library_Box = await Hive.openBox('library');
  var chapters_Box = await Hive.openBox('chapters');
  var chaptersRead_Box = await Hive.openBox('chaptersRead');
  var mangaDetails_Box = await Hive.openBox<MangaDetails>('mangaDetails');
  var mangaChapters_Box = await Hive.openBox<List<dynamic>>('mangaChapters');
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));
  runApp(MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad
        // etc.
      };
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Box settingsBox = Hive.box("settings");

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(),
      builder: (context, value, child) {
        return MaterialApp(
            title: 'Yamimo',
            scaffoldMessengerKey: snackbarKey,
            // scrollBehavior: MyCustomScrollBehavior(),
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settingsBox.get("darkMode", defaultValue: false)
                ? ThemeMode.light
                : ThemeMode.dark,
            home: ResponsiveLayout(
                mobileLayout: MyHomePage(title: 'Flutter'),
                desktopLayout: DesktopLayout()));
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PackageInfo? info = PackageInfo(
      appName: 'Yamimo',
      packageName: 'com.app.yamimo',
      version: '1.0.0',
      buildNumber: '1.0.0');

  Map<dynamic, dynamic> _updateInfo = {};
  var version;
  Box settingsBox = Hive.box('settings');
  int currentIndex = 0;
  final List<String> _screenNames = ['Library', 'Explore', 'More'];
  final List<Widget> _screens = const [
    Home(
      key: Key('Home'),
    ),
    Browse(
      key: Key('Browse'),
    ),
    More(
      key: Key('More'),
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex = _screenNames
        .indexOf(settingsBox.get('startScreen', defaultValue: 'Library'));
    // getPackage();
    fetchGithub(
      "BrumaMan",
      "Yamimo",
      "application/vnd.android.package-archive",
      // "v$version",
      "Yamimo-v${version}.apk",
    );
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

  Future<void> fetchGithub(
      String user, String packageName, String type, String appName) async {
    await getPackage();
    DateTime lastCheckedDate =
        settingsBox.get('updateCheckedDate', defaultValue: DateTime.now());
    bool updateShown = settingsBox.get('updateShown', defaultValue: false);
    Map<String, dynamic> results = {"assetUrl": ""};
    final client = HttpClient();
    client.userAgent = "auto_update";

    final request = await client.getUrl(Uri.parse(
        "https://api.github.com/repos/$user/$packageName/releases/latest"));
    final response = await request.close();

    if (response.statusCode == 200) {
      final contentAsString = await utf8.decodeStream(response);
      final Map<dynamic, dynamic> map = json.decode(contentAsString);
      // print(map);
      if (map["tag_name"] != null &&
          map["tag_name"] != version &&
          map["assets"] != null) {
        for (Map<dynamic, dynamic> asset in map["assets"]) {
          if ((asset["content_type"] != null &&
                  asset["content_type"] == type) &&
              (asset["name"] != null && asset["name"] != appName)) {
            print("here");
            results["assetUrl"] = asset["browser_download_url"] ?? '';
            results["body"] = map["body"] ?? '';
            results["tag"] = map["tag_name"] ?? '';
            results['size'] = asset["size"] ?? 0;
          }
        }
      }
    }

    setState(() {
      _updateInfo = results;
    });
    if (lastCheckedDate.toIso8601String().split('T')[0] !=
        DateTime.now().toIso8601String().split('T')[0]) {
      updateShown = false;
    }
    settingsBox.put('updateCheckedDate', DateTime.now());
    Future.delayed(Duration(milliseconds: 500), () {
      // debugPrint(version);
      if (_updateInfo['tag'] != "v$version" && !updateShown) {
        settingsBox.put('updateShown', true);
        Navigator.of(context).push(PageAnimationWrapper(
            key: ValueKey('Update'),
            screen: UpdateScreen(updateInfo: _updateInfo)));
      }
    });
  }

  TextStyle getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.selected,
    };
    if (states.any(interactiveStates.contains)) {
      return settingsBox.get("darkMode", defaultValue: false)
          ? const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          : const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
    }
    return settingsBox.get("darkMode", defaultValue: false)
        ? const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
        : const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: BottomBarPageTransition(
        builder: (context, index) => _screens[index],
        currentIndex: currentIndex,
        totalLength: _screens.length,
        transitionType: TransitionType.fade,
        transitionDuration: Duration(milliseconds: 100),
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: settingsBox.listenable(),
        builder: (context, value, child) {
          return NavigationBar(
            indicatorColor: Theme.of(context).colorScheme.inversePrimary,
            destinations: [
              NavigationDestination(
                  icon: Icon(Icons.collections_bookmark_outlined,
                      color: settingsBox.get("darkMode", defaultValue: false)
                          ? white
                          : black),
                  selectedIcon: Icon(Icons.collections_bookmark,
                      color: settingsBox.get("darkMode", defaultValue: false)
                          ? white
                          : black),
                  label: 'Library'),
              NavigationDestination(
                  icon: Icon(Icons.explore_outlined,
                      color: settingsBox.get("darkMode", defaultValue: false)
                          ? white
                          : black),
                  selectedIcon: Icon(Icons.explore,
                      color: settingsBox.get("darkMode", defaultValue: false)
                          ? white
                          : black),
                  label: 'Explore'),
              NavigationDestination(
                  icon: Icon(Icons.more_horiz,
                      color: settingsBox.get("darkMode", defaultValue: false)
                          ? white
                          : black),
                  label: 'More'),
            ],
            onDestinationSelected: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            selectedIndex: currentIndex,
            // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          );
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
