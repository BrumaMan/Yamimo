import 'dart:ui';

import 'package:first_app/search_result_all.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class Author {
  final String id;
  final String? name;
  final String? imageUrl;
  final String? bio;

  Author({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.bio,
  });
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  var authors;
  int authorCount = 0;

  @override
  void initState() {
    super.initState();
    authors = getRequest();
  }

  Future<List<Author>> getRequest() async {
    //replace your restFull API here.
    Uri url = Uri.https("api.mangadex.org", "/author", {'limit': '100'});
    final response = await http.get(url);

    var responseData = convert.jsonDecode(response.body)["data"];

    // print(responseData);

    //Creating a list to store input data;
    List<Author> authors = [];
    int index = 0;
    for (var singleAuthor in responseData) {
      Author tag = Author(
        id: singleAuthor["id"],
        name: singleAuthor["attributes"]["name"],
        imageUrl: singleAuthor["attributes"]["imageUrl"],
        bio: singleAuthor["attributes"]["biography"]["en"],
      );
      authors.add(tag);
    }
    authors.sort((a, b) => a.name!.compareTo(b.name!));
    setState(() {
      authorCount = authors.length;
    });
    return authors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authors'),
      ),
      body: FutureBuilder<List<Author>>(
          future: authors,
          builder: ((context, snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                  itemCount: authorCount,
                  itemBuilder: ((context, index) {
                    return GestureDetector(
                      child: SizedBox(
                        height: 80.0,
                        child: Card(
                          margin: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          color: Colors.blue[400],
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                '${snapshot.data?[index].name}',
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // onTap: () {
                      //   Navigator.of(context).push(CupertinoPageRoute(
                      //       builder: ((context) => SearchResultAll(
                      //             genre: '',
                      //             author: snapshot.data?[index],
                      //           ))));
                      // },
                    );
                  }));
            }
          })),
    );
  }
}
