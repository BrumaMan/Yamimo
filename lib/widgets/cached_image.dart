import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class CachedImage extends StatefulWidget {
  const CachedImage({super.key, required this.cover});

  final String cover;

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return OptimizedCacheImage(
      imageUrl: widget.cover,
      fit: BoxFit.cover,
      errorWidget: (context, error, stackTrace) => Center(
        child: Text("Can't load cover"),
      ),
      // height: 60.0,
    );
  }
}
