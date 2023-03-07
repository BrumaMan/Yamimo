import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AdvancedSettings extends StatefulWidget {
  const AdvancedSettings({super.key});

  @override
  State<AdvancedSettings> createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  String thumbnailCacheSize = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCacheSize();
  }

  Future<int> getCacheSize() async {
    Directory tempDir = await getTemporaryDirectory();
    int tempDirSize = _getSize(tempDir);
    setState(() {
      thumbnailCacheSize = filesize(tempDirSize);
    });
    return tempDirSize;
  }

  int _getSize(FileSystemEntity file) {
    if (file is File) {
      return file.lengthSync();
    } else if (file is Directory) {
      int sum = 0;
      List<FileSystemEntity> children = file.listSync();
      for (FileSystemEntity child in children) {
        sum += _getSize(child);
      }
      return sum;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced'),
      ),
      body: Column(children: [
        ListTile(
          title: Text('Clear Thumbnail cache'),
          subtitle: Text('Used: $thumbnailCacheSize'),
          onTap: () async {
            await DefaultCacheManager().emptyCache();
            getCacheSize();
          },
        )
      ]),
    );
  }
}
