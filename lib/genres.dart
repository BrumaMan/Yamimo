import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class GenresScreen extends StatefulWidget {
  const GenresScreen({super.key});

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class Tag {
  final String id;
  final String? name;

  Tag({
    required this.id,
    required this.name,
  });
}

class _GenresScreenState extends State<GenresScreen> {
  var tags;
  List<Widget> tabs = [];
  List<Widget> tabViews = [];
  int tagCount = 0;

  @override
  void initState() {
    super.initState();
    tags = getRequest();
  }

  Future<List<Tag>> getRequest() async {
    //replace your restFull API here.
    Uri url = Uri.https("api.mangadex.org", "/manga/tag");
    final response = await http.get(url);

    var responseData = convert.jsonDecode(response.body)["data"];

    // print(responseData);

    //Creating a list to store input data;
    responseData
        .removeWhere((element) => element["attributes"]["group"] != 'genre');
    List<Tag> tags = [];
    for (var singleTag in responseData) {
      Tag tag = Tag(
        id: singleTag["id"],
        name: singleTag["attributes"]["name"]["en"],
      );
      tags.add(tag);
    }
    tags.sort((a, b) => a.name!.compareTo(b.name!));
    for (var tab in tags) {
      tabs.add(Tab(
        text: tab.name,
      ));
      // tabViews.add(SearchResultAll(genre: tab.id));
    }
    setState(() {
      tagCount = tags.length;
    });
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tagCount,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Genres'),
          bottom: TabBar(
              // padding: EdgeInsets.only(bottom: 8.0),
              labelPadding:
                  EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
              indicatorSize: TabBarIndicatorSize.label,
              // indicatorPadding: EdgeInsets.symmetric(horizontal: 16.0),
              isScrollable: true,
              tabs: tabs),
        ),
        body: FutureBuilder<List<Tag>>(
            future: tags,
            builder: ((context, snapshot) {
              if (snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return TabBarView(children: tabViews);
              }
            })),
      ),
    );
  }
}
