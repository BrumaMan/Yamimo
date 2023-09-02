import 'package:auto_update/auto_update.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key, required this.updateInfo});

  final Map<dynamic, dynamic> updateInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Icon(Icons.new_releases_outlined,
                  size: 50.0, color: Theme.of(context).colorScheme.primary),
            ),
            Text(
              'New version available!',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(updateInfo['tag']),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text('Size: ${filesize(updateInfo['size'])}'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: MarkdownBody(data: updateInfo['body']),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.background.withOpacity(0.02),
        surfaceTintColor: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Not now')),
            )),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FilledButton(
                  onPressed: () async {
                    await AutoUpdate.downloadAndUpdate(updateInfo['assetUrl']);
                  },
                  child: Text('Download')),
            ))
          ],
        ),
      ),
    );
  }
}
