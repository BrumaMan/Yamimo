import 'package:flutter/material.dart';
import 'package:first_app/browse.dart';
import 'package:first_app/home.dart';
import 'package:first_app/more.dart';
import 'package:first_app/search_result.dart';
import 'package:status_bar_control/status_bar_control.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DesktopLayout extends StatefulWidget {
  const DesktopLayout({super.key});

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  Box settingsBox = Hive.box('settings');
  int _counter = 0;
  int currentIndex = 0;
  final List<String> _screenNames = ['Library', 'Explore', 'More'];
  final List<Widget> _screens = const [
    Home(),
    Browse(),
    More(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex = _screenNames
        .indexOf(settingsBox.get('startScreen', defaultValue: 'Library'));
  }

  TextStyle getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.selected,
    };
    if (states.any(interactiveStates.contains)) {
      return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
    }
    return const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold);
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
      body: Row(
        children: [
          NavigationRail(
              backgroundColor: Colors.white.withOpacity(0.08),
              indicatorColor: Colors.blue[400],
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                    icon: Icon(Icons.collections_bookmark_outlined,
                        color: Colors.white),
                    selectedIcon:
                        Icon(Icons.collections_bookmark, color: Colors.white),
                    label: Text('Library')),
                NavigationRailDestination(
                    icon: Icon(Icons.explore_outlined, color: Colors.white),
                    selectedIcon: Icon(Icons.explore, color: Colors.white),
                    label: Text('Explore')),
                NavigationRailDestination(
                    icon: Icon(Icons.more_horiz, color: Colors.white),
                    label: Text('More')),
              ],
              onDestinationSelected: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              selectedIndex: currentIndex),
          Expanded(child: _screens[currentIndex]),
        ],
      ),
      // bottomNavigationBar: Theme(
      //   data: ThemeData(splashColor: Colors.transparent),
      //   child: NavigationBarTheme(
      //     data: NavigationBarThemeData(
      //         surfaceTintColor: Colors.black,
      //         backgroundColor: Colors.white.withOpacity(0.08),
      //         indicatorColor: Colors.blue[400],
      //         labelTextStyle: MaterialStateProperty.resolveWith(
      //             (states) => getColor(states))),
      //     child: NavigationBar(
      //       destinations: const [
      //         NavigationDestination(
      //             icon: Icon(Icons.collections_bookmark_outlined,
      //                 color: Colors.white),
      //             selectedIcon:
      //                 Icon(Icons.collections_bookmark, color: Colors.white),
      //             label: 'Library'),
      //         NavigationDestination(
      //             icon: Icon(Icons.explore_outlined, color: Colors.white),
      //             selectedIcon: Icon(Icons.explore, color: Colors.white),
      //             label: 'Explore'),
      //         NavigationDestination(
      //             icon: Icon(Icons.more_horiz, color: Colors.white),
      //             label: 'More'),
      //       ],
      //       onDestinationSelected: (int index) {
      //         setState(() {
      //           currentIndex = index;
      //         });
      //       },
      //       selectedIndex: currentIndex,
      //       // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      //     ),
      //   ),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
