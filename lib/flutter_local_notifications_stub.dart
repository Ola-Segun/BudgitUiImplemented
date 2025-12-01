// Stub implementation for Flutter Local Notifications on web
class FlutterLocalNotificationsPlugin {
  Future<void> show(int id, String? title, String? body, dynamic details, {String? payload}) async {}
}

class AndroidNotificationDetails {
  AndroidNotificationDetails(
    this.channelId,
    this.channelName, {
    this.channelDescription,
    this.importance,
    this.priority,
    this.showWhen,
    this.icon,
  });

  final String channelId;
  final String channelName;
  final String? channelDescription;
  final dynamic importance;
  final dynamic priority;
  final bool? showWhen;
  final String? icon;
}

class DarwinNotificationDetails {
  DarwinNotificationDetails({
    this.presentAlert,
    this.presentBadge,
    this.presentSound,
  });

  final bool? presentAlert;
  final bool? presentBadge;
  final bool? presentSound;
}

class NotificationDetails {
  NotificationDetails({
    this.android,
    this.iOS,
  });

  final AndroidNotificationDetails? android;
  final DarwinNotificationDetails? iOS;
}

class Importance {
  static const high = 'high';
}

class Priority {
  static const high = 'high';
}