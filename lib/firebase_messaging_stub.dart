// Stub implementation for Firebase Messaging on web
class FirebaseMessaging {
  static dynamic get instance => null;
  static dynamic get onMessage => null;
  static dynamic get onMessageOpenedApp => null;
  static dynamic get onBackgroundMessage => null;
}

class AuthorizationStatus {
  static const authorized = 'authorized';
}

class RemoteMessage {
  final String? messageId;
  final dynamic notification;
  final Map<String, dynamic> data;

  RemoteMessage({
    this.messageId,
    this.notification,
    this.data = const {},
  });
}