import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MangaCoverView extends StatelessWidget {
  const MangaCoverView({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: InteractiveViewer(
        minScale: 1.0,
        // maxZoomHeight: 1550,
        // maxZoomWidth: 1200,
        // initZoom: 0.0,
        // canvasColor: Colors.transparent,
        // backgroundColor: Colors.transparent,
        // opacityScrollBars: 0.0,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
