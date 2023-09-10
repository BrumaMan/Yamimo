import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static Future initalize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    var androidInitialize =
        AndroidInitializationSettings('@drawable/notification_icon');
    var initsettings = InitializationSettings(android: androidInitialize);
    await flutterLocalNotificationsPlugin.initialize(initsettings);
  }

  static Future<void> showNotification(
      int id,
      String title,
      String body,
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      String channelID,
      String channelName,
      {maxProgress = 0,
      progress = 0,
      showProgress = false}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelID, // Change this to a unique ID
      channelName,
      channelDescription: 'Show local notifications',
      playSound: false,
      showProgress: showProgress,
      maxProgress: maxProgress,
      progress: progress,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
