import 'dart:ui';

import 'package:first_app/authors.dart';
import 'package:first_app/genres.dart';
import 'package:first_app/search_result.dart';
import 'package:first_app/search_result_all.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Browse extends StatefulWidget {
  const Browse({super.key});

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  late TextEditingController textController;
  List<String> providers = [
    'All Manga',
    'Genres',
    'Authors',
  ];

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
        const SliverAppBar(
          title: Text('Explore'),
          snap: true,
          floating: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  // CupertinoSearchTextField(
                  //   controller: textController,
                  //   placeholder: 'Search',
                  //   placeholderStyle: const TextStyle(color: Colors.white),
                  //   style: const TextStyle(color: Colors.white),
                  //   backgroundColor: Colors.grey[700],
                  //   onSubmitted: (value) {
                  //     Navigator.of(context).push(CupertinoPageRoute(
                  //       builder: (context) {
                  //         return SearchResult(searchTerm: textController.text);
                  //       },
                  //     ));
                  //   },
                  // ),
                  Container(
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                      hintText: "Search",
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.grey,
                      prefixIcon: Icon(Icons.search)),
                  onSubmitted: (value) {
                    Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) {
                        return SearchResult(searchTerm: textController.text);
                      },
                    ));
                  },
                ),
              )),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate(
          childCount: providers.length,
          (context, index) {
            return GestureDetector(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      Image.asset(
                          scale: 1.0,
                          alignment: index != 2
                              ? Alignment(-1.0, -0.8)
                              : Alignment(0.0, 0.0),
                          height: 150.0,
                          width: 500,
                          fit: BoxFit.none,
                          backImages[index]),
                      Positioned(
                          bottom: 0.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.black.withOpacity(0.0)
                                ])
                                //   boxShadow: [
                                //   BoxShadow(
                                //       offset: Offset(0.0, 0.0),
                                //       spreadRadius: 2.0,
                                //       blurStyle: BlurStyle.normal,
                                //       blurRadius: 2.0,
                                //       color: Colors.black.withOpacity(0.4)),
                                //   BoxShadow(
                                //       offset: Offset(0.0, 0.0),
                                //       spreadRadius: 2.0,
                                //       blurStyle: BlurStyle.outer,
                                //       blurRadius: 2.0,
                                //       color: Colors.black.withOpacity(0.1)),
                                //   BoxShadow(
                                //       offset: Offset(0.0, 0.0),
                                //       spreadRadius: 2.0,
                                //       blurStyle: BlurStyle.outer,
                                //       blurRadius: 2.0,
                                //       color: Colors.black.withOpacity(0.2)),
                                //   BoxShadow(
                                //       offset: Offset(0.0, 0.0),
                                //       spreadRadius: 2.0,
                                //       blurStyle: BlurStyle.outer,
                                //       blurRadius: 2.0,
                                //       color: Colors.black.withOpacity(0.1))
                                // ],
                                ),
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              providers[index],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              onTap: () {
                if (index == 0) {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: ((context) => SearchResultAll(
                            genre: '',
                          ))));
                } else if (index == 1) {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: ((context) => GenresScreen())));
                } else if (index == 2) {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: ((context) => AuthorsScreen())));
                }
              },
            );
          },
        ))
      ],
    ));
  }
}
