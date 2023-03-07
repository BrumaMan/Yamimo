import 'dart:io';

import 'package:first_app/item_view.dart';
import 'package:first_app/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_bar_control/status_bar_control.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

enum MenuItems { Default, leftToRight, vertical, webtoon, continuousVertical }

class ChapterView extends StatefulWidget {
  const ChapterView(
      {super.key,
      required this.id,
      required this.mangaId,
      required this.title,
      required this.chapterCount,
      required this.order,
      required this.chapters,
      required this.index,
      required this.url});

  final String id;
  final String mangaId;
  final String title;
  final int chapterCount;
  final int order;
  final List<dynamic>? chapters;
  final int index;
  final String url;

  @override
  State<ChapterView> createState() => _ChapterViewState();
}

class _ChapterViewState extends State<ChapterView>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  late AnimationController _controller;
  late PreloadPageController pageController;
  // late double height = MediaQuery.of(context).padding.top;
  var pages;
  Box settingsBox = Hive.box('settings');
  Box chaptersReadBox = Hive.box('chaptersRead');
  List<Widget> pageViews = [];
  Map<MenuItems, IconData> readerIcons = {
    MenuItems.Default: Icons.app_settings_alt_outlined,
    MenuItems.leftToRight: Icons.send_to_mobile_outlined,
    MenuItems.vertical: Icons.system_security_update_outlined,
    MenuItems.webtoon: Icons.system_security_update_outlined,
    MenuItems.continuousVertical: Icons.system_security_update_outlined,
  };
  var chapterInitialPage = 0;
  var chaptersRead;
  bool visible = true;
  int order = 0;
  int pageCount = 1;
  int chapterOffset = 0;
  int chapterNumber = 0;
  bool hasNextChapter = true;
  bool hasPrevChapter = true;
  MenuItems? selectedMenu;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReaderMode();
    // chapterNumber = widget.chapterCount;
    !Platform.isWindows ? StatusBarControl.setTranslucent(true) : null;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));

    // SystemChrome.setEnabledSystemUIMode(
    //   SystemUiMode.leanBack,
    // );
    chaptersRead = chaptersReadBox.get(widget.mangaId);
    addChapterToRead(widget.id);
    pageController = PreloadPageController(initialPage: chapterInitialPage);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    pages = getRequest();
    settingsBox.get('showReaderMode', defaultValue: true) && !Platform.isWindows
        ? Fluttertoast.showToast(
            msg: '${selectedMenu.toString().split('.')[1]}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0)
        : null;
    // debugPrint('${widget.chapters}');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scrollController.dispose();
    _controller.dispose();
    pageController.dispose();
    showStatusBar();
    StatusBarControl.setTranslucent(false);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  void getReaderMode() {
    String tempReaderMode;
    if (settingsBox.containsKey('readerMode')) {
      // settingsBox.put('readerMode', 'MenuItems.Default');
      tempReaderMode = settingsBox.get('readerMode');
    } else {
      tempReaderMode =
          settingsBox.get('readerMode', defaultValue: '${MenuItems.Default}');
    }

    switch (tempReaderMode) {
      case 'MenuItems.Default':
        selectedMenu = MenuItems.Default;
        debugPrint('de');
        break;
      case 'MenuItems.leftToRight':
        selectedMenu = MenuItems.leftToRight;
        debugPrint('lr');
        break;
      case 'MenuItems.vertical':
        selectedMenu = MenuItems.vertical;
        debugPrint('ver');
        break;
      case 'MenuItems.webtoon':
        selectedMenu = MenuItems.webtoon;
        debugPrint('web');
        break;
      case 'MenuItems.continuousVertical':
        selectedMenu = MenuItems.continuousVertical;
        debugPrint('cv');
        break;
    }
    // return readerMode;
  }

  Future<List<String>> getRequest() async {
    //replace your restFull API here.
    String id = widget.chapters![widget.index + chapterOffset].id;
    // chapterInitialPage = 0;
    Uri url = Uri.https("api.mangadex.org", "/at-home/server/$id");
    final response = await http.get(url);

    var responseData = convert.jsonDecode(response.body);
    String? baseUrl = responseData["baseUrl"];
    String? hash = responseData["chapter"]?["hash"];

    // print(responseData);

    //Creating a list to store input data;
    List<String> pages = [];
    List<Widget> tempPageViews = [];
    int index = 0;
    try {
      for (var page in responseData["chapter"]["data"]) {
        //Adding user to the list.
        pages.add('$baseUrl/data/$hash/$page');
        tempPageViews.add(InteractiveViewer(
          clipBehavior: Clip.none,
          child: Image.network(
            '$baseUrl/data/$hash/$page',
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text("Can't load page"),
              );
            },
          ),
        ));
        // index + 1;
      }
    } catch (e) {
      pages.add('https://icons8.com/icon/21066/unavailable');
    }
    // chapters.reversed;
    setState(() {
      pageCount = pages.length;
      pageViews = tempPageViews;
    });
    return pages;
  }

  void nextChapter() {
    setState(() {
      chapterOffset = chapterOffset - 1;
      chapterNumber = chapterNumber + 1;
    });
    bool? next = widget.order + chapterNumber <= widget.chapterCount;
    if (next == false) {
      setState(() {
        hasNextChapter = false;
      });
      debugPrint('one');
    } else if (hasPrevChapter == false) {
      setState(() {
        hasPrevChapter = true;
      });
      debugPrint('two');
      pageViews = [];
      pages = getRequest();
      addChapterToRead(widget.chapters![widget.index + chapterOffset].id);
    } else {
      pageViews = [];
      pages = getRequest();
      addChapterToRead(widget.chapters![widget.index + chapterOffset].id);
      // debugPrint('${pageViews.length}');
    }
  }

  void previousChapter() {
    setState(() {
      chapterOffset = chapterOffset + 1;
      chapterNumber = chapterNumber - 1;
    });
    bool? prev = widget.order + chapterNumber > 0;
    if (prev == false) {
      setState(() {
        hasPrevChapter = false;
      });
    } else if (hasNextChapter == false) {
      setState(() {
        hasNextChapter = true;
      });
      debugPrint('two');
      pageViews = [];
      pages = getRequest();
      addChapterToRead(widget.chapters![widget.index + chapterOffset].id);
    } else {
      pageViews = [];
      pages = getRequest();
      addChapterToRead(widget.chapters![widget.index + chapterOffset].id);
      // debugPrint('${pageViews.length}');
    }
  }

  void hideStatusBar() {
    // StatusBarControl.setHidden(true);
    // StatusBarControl.setTranslucent(true);
    // StatusBarControl.setNavigationBarColor(Color(0x00FFFFFF));
    !Platform.isWindows
        ? StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT)
        : null;
  }

  void showStatusBar() {
    // StatusBarControl.setHidden(false);
    // StatusBarControl.setTranslucent(false);
    !Platform.isWindows
        ? StatusBarControl.setStyle(StatusBarStyle.LIGHT_CONTENT)
        : null;
  }

  Color getBgColor() {
    String bgColor = settingsBox.get('readerBgColor', defaultValue: 'Black');

    switch (bgColor) {
      case 'Black':
        return Colors.black;

      case 'Gray':
        return Colors.grey;

      case 'White':
        return Colors.white;
      default:
        return Colors.black;
    }
  }

  void addChapterToRead(String id) {
    if (!chaptersRead.containsKey(id)) {
      chaptersRead.addAll({
        id: {'read': false, 'page': 0}
      });
    }
    chapterInitialPage = chaptersRead[id]['page'] == 0
        ? chaptersRead[id]['page']
        : chaptersRead[id]['page'] - 1;
  }

  void updateChapter() {
    if (chapterInitialPage + 1 > 1 &&
        chapterInitialPage + 1 <= pageCount &&
        !chaptersRead[widget.chapters![widget.index + chapterOffset].id]
            ['read']) {
      chaptersRead.update(
          widget.chapters![widget.index + chapterOffset].id,
          (value) => {
                'read': chapterInitialPage + 1 < pageCount ? false : true,
                'page': chapterInitialPage + 1 < pageCount
                    ? chapterInitialPage + 1
                    : 0
              });
      chaptersReadBox.put(widget.mangaId, chaptersRead);
    }
  }

  @override
  Widget build(BuildContext context) {
    // hideAppBar();
    return Scaffold(
      backgroundColor: getBgColor(),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 50),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -_controller.value * 140),
            child: Container(
              decoration: BoxDecoration(
                  color: settingsBox.get('darkMode', defaultValue: false)
                      ? Colors.black
                      : Colors.white),
              padding: EdgeInsets.only(top: 50.0),
              child: AppBar(
                // titleTextStyle: TextStyle(color: Colors.white, fontSize: 16.0),
                // iconTheme: IconThemeData(color: Colors.white),
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.white.withOpacity(0.7),
                title: Text(
                    widget.chapters!.length - 1 < widget.index + chapterOffset
                        ? 'No title'
                        : widget.chapters![widget.index + chapterOffset].title),
                // toolbarOpacity: opacity,
                toolbarHeight: kToolbarHeight,
                // flexibleSpace: Container(
                //   height: 40.0,
                // ),
                actions: [
                  IconButton(
                      onPressed: () {
                        Share.share(
                            'https://mangadex.org/chapter/${widget.chapters![widget.index + chapterOffset].id}/1');
                      },
                      icon: Icon(Icons.share_outlined)),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => WebView(
                                url:
                                    'https://mangadex.org/chapter/${widget.chapters![widget.index + chapterOffset].id}/1',
                                title: widget
                                    .chapters![widget.index + chapterOffset]
                                    .title)));
                      },
                      icon: Icon(Icons.public_outlined)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // try {
            //   if (scrollController.position.userScrollDirection ==
            //       ScrollDirection.reverse) {
            //     setState(() {
            //       visible = false;
            //     });
            //     hideStatusBar();

            //     _controller.forward();
            //   }
            // } catch (e) {
            //   setState(() {
            //     visible = false;
            //   });
            //   hideStatusBar();

            //   _controller.forward();
            // }

            // try {
            //   if (scrollController.position.userScrollDirection ==
            //       ScrollDirection.forward) {
            //     setState(() {
            //       visible = false;
            //     });
            //     hideStatusBar();

            //     _controller.forward();
            //   }
            // } catch (e) {
            //   // setState(() {
            //   //   visible = false;
            //   // });
            //   // hideStatusBar();
            //   // debugPrint('here');

            //   // _controller.forward();
            // }
            return true;
          },
          child: FutureBuilder<List<String>>(
              future: pages,
              builder: ((context, snapshot) {
                if (snapshot.data == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return !hasNextChapter || !hasPrevChapter
                      ? Center(
                          child: Text(
                            'No more chapters',
                            style: TextStyle(
                                color: settingsBox.get('readerBgColor',
                                                defaultValue: 'Black') ==
                                            'Black' ||
                                        settingsBox.get('readerBgColor') ==
                                            'Gray'
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        )
                      : GestureDetector(
                          child: Stack(
                            children: [
                              pageViews.isNotEmpty
                                  ? InteractiveViewer(
                                      child: PreloadPageView.builder(
                                        preloadPagesCount: 3,
                                        itemCount: pageViews.length,
                                        controller: pageController,
                                        pageSnapping: selectedMenu ==
                                                    MenuItems.webtoon ||
                                                selectedMenu ==
                                                    MenuItems.continuousVertical
                                            ? false
                                            : true,
                                        reverse: selectedMenu ==
                                                MenuItems.leftToRight
                                            ? false
                                            : selectedMenu ==
                                                        MenuItems.vertical ||
                                                    selectedMenu ==
                                                        MenuItems.webtoon ||
                                                    selectedMenu ==
                                                        MenuItems
                                                            .continuousVertical
                                                ? false
                                                : true,
                                        scrollDirection: selectedMenu ==
                                                    MenuItems.vertical ||
                                                selectedMenu ==
                                                    MenuItems.webtoon ||
                                                selectedMenu ==
                                                    MenuItems.continuousVertical
                                            ? Axis.vertical
                                            : Axis.horizontal,
                                        onPageChanged: (value) => setState(() {
                                          chapterInitialPage = value;
                                          updateChapter();
                                        }),
                                        itemBuilder: (context, index) {
                                          try {
                                            return Column(
                                              children: [
                                                Expanded(
                                                  child: Image.network(
                                                    snapshot.data![index],
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    fit: selectedMenu ==
                                                                MenuItems
                                                                    .webtoon ||
                                                            selectedMenu ==
                                                                MenuItems
                                                                    .continuousVertical
                                                        ? BoxFit.fill
                                                        : BoxFit.contain,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Center(
                                                        child: Text(
                                                            "Can't load page"),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: selectedMenu ==
                                                          MenuItems.webtoon ||
                                                      selectedMenu ==
                                                          MenuItems
                                                              .continuousVertical,
                                                  child: Padding(
                                                      padding: EdgeInsets.all(
                                                          selectedMenu ==
                                                                  MenuItems
                                                                      .webtoon
                                                              ? 0.0
                                                              : 12.0)),
                                                )
                                              ],
                                            );
                                          } catch (e) {
                                            return Center(
                                              child: Text("Can't load page"),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              Positioned(
                                bottom: 20.0,
                                width: MediaQuery.of(context).size.width,
                                child: Stack(
                                    alignment:
                                        AlignmentDirectional.bottomCenter,
                                    children: [
                                      Text(
                                        '${chapterInitialPage + 1}/${pageViews.length}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            foreground: Paint()
                                              ..style = PaintingStyle.stroke
                                              ..strokeWidth = 2
                                              ..color = Colors.black),
                                      ),
                                      Text(
                                          '${chapterInitialPage + 1}/${pageViews.length}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: settingsBox.get(
                                                              'readerBgColor',
                                                              defaultValue:
                                                                  'Black') ==
                                                          'Black' ||
                                                      settingsBox.get(
                                                              'readerBgColor') ==
                                                          'Gray'
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ]),
                              )
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              visible = !visible;
                              visible ? showStatusBar() : hideStatusBar();
                              if (_controller.isCompleted) {
                                _controller.reverse();
                              } else {
                                _controller.forward();
                              }
                            });
                          },
                        );
                }
              }))),
      bottomNavigationBar: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _controller.value * 120),
          child: BottomAppBar(
            color: Colors.black,
            surfaceTintColor: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: settingsBox.listenable(),
                      builder: (context, value, child) {
                        return PopupMenuButton<MenuItems>(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          // color: Colors.black,
                          icon: Icon(
                            readerIcons[selectedMenu],
                            color:
                                settingsBox.get("darkMode", defaultValue: false)
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          // position: PopupMenuPosition.under,
                          // offset: Offset(0, 0.0),
                          color:
                              settingsBox.get("darkMode", defaultValue: false)
                                  ? Colors.black
                                  : Colors.white,
                          initialValue: selectedMenu,
                          onSelected: (MenuItems item) {
                            if (item == MenuItems.Default) {}
                            setState(() {
                              debugPrint(
                                  Theme.of(context).useMaterial3.toString());
                              selectedMenu = item;
                              settingsBox.put('readerMode', '$selectedMenu');
                            });
                          },
                          itemBuilder: (context) => <PopupMenuEntry<MenuItems>>[
                            CheckedPopupMenuItem<MenuItems>(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              checked: selectedMenu == MenuItems.Default
                                  ? true
                                  : false,
                              value: MenuItems.Default,
                              child: Text('Default'),
                            ),
                            CheckedPopupMenuItem<MenuItems>(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              checked: selectedMenu == MenuItems.leftToRight
                                  ? true
                                  : false,
                              value: MenuItems.leftToRight,
                              child: Text('Left to right'),
                            ),
                            CheckedPopupMenuItem<MenuItems>(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              checked: selectedMenu == MenuItems.vertical
                                  ? true
                                  : false,
                              value: MenuItems.vertical,
                              child: Text('Vertical'),
                            ),
                            CheckedPopupMenuItem<MenuItems>(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              checked: selectedMenu == MenuItems.webtoon
                                  ? true
                                  : false,
                              value: MenuItems.webtoon,
                              child: Text('Webtoon'),
                            ),
                            CheckedPopupMenuItem<MenuItems>(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              checked:
                                  selectedMenu == MenuItems.continuousVertical
                                      ? true
                                      : false,
                              value: MenuItems.continuousVertical,
                              child: Text('Continous vertical'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Visibility(
                      visible:
                          !hasNextChapter || !hasPrevChapter ? false : true,
                      child: Slider(
                        value: chapterInitialPage.toDouble(),
                        label: '${chapterInitialPage + 1}',
                        divisions: pageViews.isEmpty
                            ? pageViews.length + 1
                            : pageViews.length - 1,
                        min: 0.0,
                        max: pageViews.isEmpty
                            ? chapterInitialPage.toDouble()
                            : pageViews.length.toDouble() - 1.0,
                        onChanged: (value) {
                          setState(() {
                            chapterInitialPage = value.toInt();
                          });
                          pageController.jumpToPage(chapterInitialPage);
                        },
                      ),
                    )),
                Row(
                  children: [
                    IconButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                      onPressed: (() {
                        previousChapter();
                      }),
                      icon: Icon(
                        Icons.arrow_left,
                        size: 40.0,
                      ),
                    ),
                    IconButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                      onPressed: (() {
                        nextChapter();
                      }),
                      icon: Icon(
                        Icons.arrow_right,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
