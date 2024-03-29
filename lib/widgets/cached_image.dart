// ignore_for_file: must_call_super

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
      placeholder: (context, url) => Icon(
        Icons.image_outlined,
        size: 50.0,
      ),
      imageUrl: widget.cover,
      fit: BoxFit.cover,
      errorWidget: (context, error, stackTrace) => Center(
        child: Icon(
          Icons.broken_image,
          size: 50.0,
        ),
      ),
      // height: 60.0,
    );
  }
}
