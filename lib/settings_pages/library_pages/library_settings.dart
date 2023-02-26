import 'package:first_app/settings_pages/library_pages/display.dart';
import 'package:flutter/material.dart';

class LibrarySettings extends StatelessWidget {
  const LibrarySettings({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> parts = [
      Display(context: context),
      // Display(context: context),
      // Display(context: context),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Library'),
      ),
      body: ListView.separated(
          itemBuilder: ((context, index) {
            return parts[index];
          }),
          separatorBuilder: ((context, index) => Divider(
                color: Colors.grey,
              )),
          itemCount: 1),
    );
  }
}
