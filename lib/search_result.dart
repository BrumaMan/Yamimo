import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/util/globals.dart';
import 'package:first_app/widgets/search_source_results.dart';
import 'package:flutter/material.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({super.key, required this.searchTerm});

  final String searchTerm;

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  late TextEditingController textController;
  late ScrollController scrollViewController;

  var comics;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.searchTerm);
    scrollViewController = ScrollController();
    sources.sort((a, b) => a.compareTo(b));
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: sources.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.searchTerm),
            bottom: TabBar(
              tabs: sources
                  .map((e) => Tab(
                        text: e,
                      ))
                  .toList(),
              // isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
          body: TabBarView(
            children: sources
                .map((e) =>
                    SearchSourceResults(name: e, query: widget.searchTerm))
                .toList(),
          ),
        ));
  }
}
