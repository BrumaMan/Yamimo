import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

enum MenuItems { item1, item2, item3 }

class WebView extends StatefulWidget {
  const WebView({super.key, required this.url, required this.title});

  final String title;
  final String url;

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final InAppWebViewController _controller;
  double progress = 0;
  bool isLoading = true;
  MenuItems? selectedMenu;
  bool canGoBack = false;
  bool canGoForward = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void canGoBackPage() async {
    if (await _controller.canGoBack()) {
      setState(() {
        canGoBack = true;
      });
    } else {
      setState(() {
        canGoBack = false;
      });
    }
  }

  void canGoForwardPage() async {
    if (await _controller.canGoForward()) {
      setState(() {
        canGoForward = true;
      });
    } else {
      setState(() {
        canGoForward = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Visibility(
            visible: isLoading,
            child: LinearProgressIndicator(
              minHeight: 4.0,
              value: progress,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
              backgroundColor: Colors.grey,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: ListTile(
          title: Text(
            widget.title,
            // maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            widget.url,
            // maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          IconButton(
              onPressed: canGoBack
                  ? () async {
                      if (await _controller.canGoBack()) {
                        _controller.goBack();
                      } else {
                        // canGoBackPage();
                      }
                    }
                  : null,
              icon: Icon(Icons.arrow_back)),
          IconButton(
              onPressed: canGoForward
                  ? () async {
                      if (await _controller.canGoForward()) {
                        _controller.goForward();
                      } else {}
                    }
                  : null,
              icon: Icon(Icons.arrow_forward)),
          PopupMenuButton<MenuItems>(
            // color: Colors.black,
            // child: Icon(Icons.more_vert),
            position: PopupMenuPosition.under,
            initialValue: selectedMenu,
            onSelected: (MenuItems item) {
              if (item == MenuItems.item1) {
                _controller.reload();
              }
              // setState(() {
              //   selectedMenu = item;
              // });
            },
            itemBuilder: (context) => <PopupMenuEntry<MenuItems>>[
              const PopupMenuItem<MenuItems>(
                value: MenuItems.item1,
                child: Text('Refresh'),
              ),
              const PopupMenuItem<MenuItems>(
                value: MenuItems.item2,
                child: Text('Share'),
              ),
              const PopupMenuItem<MenuItems>(
                value: MenuItems.item3,
                child: Text('Item 1'),
              ),
            ],
          ),
        ],
      ),
      body: InAppWebView(
        onLoadStart: (controller, url) {
          canGoBackPage();
          canGoForwardPage();
          setState(() {
            isLoading = true;
          });
        },
        onLoadStop: (controller, url) {
          setState(() {
            isLoading = false;
          });
        },
        onProgressChanged: (controller, currentProgress) {
          setState(() {
            progress = currentProgress / 100;
          });
        },
        onWebViewCreated: (controller) => _controller = controller,
        initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
      ),
    );
  }
}
