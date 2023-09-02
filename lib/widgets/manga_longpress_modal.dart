import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class LongPressModal extends StatelessWidget {
  const LongPressModal(
      {super.key,
      required this.imageURL,
      required this.title,
      required this.url,
      required this.read,
      required this.total,
      required this.source,
      required this.onDelete});

  final String imageURL;
  final String title;
  final String url;
  final int read;
  final int total;
  final String source;
  final Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                      imageUrl: imageURL, width: 60.0, height: 100.0)),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('Read: $read | Total: $total | Source: $source',
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
            ]),
          ),
          ListTile(
            title: Text('Share'),
            leading: Icon(Icons.share_outlined),
            onTap: () => Share.share(url),
          ),
          ListTile(
            title: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
            leading: Icon(Icons.delete_outlined, color: Colors.red),
            onTap: () {
              onDelete();
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
