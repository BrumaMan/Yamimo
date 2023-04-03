import 'dart:ui';

import 'package:first_app/authors.dart';
import 'package:first_app/genres.dart';
import 'package:first_app/search_result.dart';
import 'package:first_app/search_result_all.dart';
import 'package:first_app/util/globals.dart';
import 'package:first_app/widgets/source_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Browse extends StatefulWidget {
  const Browse({super.key});

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  late TextEditingController textController;
  Box settingsBox = Hive.box('settings');
  bool search = false;

  List<String> backImages = [
    'assets/c5a3090c-4ca0-40a2-9102-e0ee0c6dac15.jpg',
    'assets/71114c70-ed35-4065-b9d7-35768c200c64.jpg',
    'assets/bbf49948-d031-4034-ba22-9120d7d21e14.jpg',
  ];

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: search
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      search = !search;
                    });
                  },
                  icon: Icon(Icons.arrow_back))
              : null,
          title: search
              ? TextField(
                  controller: textController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) {
                        return SearchResult(searchTerm: textController.text);
                      },
                    ));
                  },
                )
              : Text('Explore'),
          snap: true,
          floating: true,
          actions: [
            !search
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        search = !search;
                      });
                    },
                    icon: Icon(Icons.travel_explore))
                : SizedBox.shrink(),
          ],
        ),
        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: const EdgeInsets.all(10.0),
        //     child: Row(
        //       children: [
        //         GestureDetector(
        //           child: Container(
        //             padding: const EdgeInsets.all(16.0),
        //             margin: EdgeInsets.only(right: 8.0),
        //             width: MediaQuery.of(context).size.width / 2 - 12,
        //             decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(8.0),
        //                 color: settingsBox.get('darkMode', defaultValue: false)
        //                     ? Colors.white.withOpacity(0.1)
        //                     : Colors.blue.withOpacity(0.08)),
        //             child: Row(
        //               children: [Icon(Icons.history), Text(' History')],
        //             ),
        //           ),
        //         ),
        //         GestureDetector(
        //           child: Container(
        //             padding: const EdgeInsets.all(16.0),
        //             width: MediaQuery.of(context).size.width / 2 - 18,
        //             decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(8.0),
        //                 color: settingsBox.get('darkMode', defaultValue: false)
        //                     ? Colors.white.withOpacity(0.1)
        //                     : Colors.blue.withOpacity(0.08)),
        //             child: Row(
        //               children: [
        //                 Icon(Icons.bookmark_border),
        //                 Text(' Bookmarks')
        //               ],
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                Text('Sources'),
              ],
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate(
          childCount: sources.length,
          (context, index) {
            return ListTile(
              leading: SourceImage(sourceTitle: sources[index]),
              title: Text(sources[index]),
              trailing: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: ((context) => SearchResultAll(
                              name: sources[index],
                              sort: 'Latest',
                            ))));
                  },
                  child: Text('Latest')),
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: ((context) => SearchResultAll(
                          name: sources[index],
                          sort: 'Popular',
                        ))));
              },
            );
          },
        ))
      ],
    ));
  }
}
