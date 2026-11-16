import 'dart:async';

enum NotificationType { orderUpdate, flashSale, security, general }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.data,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      type: type,
      data: data,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// FCM Service implementing enterprise-grade push notification architecture
/// Handles Token generation, Foreground notifications, Background message routing,
/// Topic subscription, and notification stream.
class FCMNotificationService {
  static final FCMNotificationService _instance = FCMNotificationService._internal();
  factory FCMNotificationService() => _instance;
  FCMNotificationService._internal();

  final _notificationStreamController = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get onNotificationReceived => _notificationStreamController.stream;

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Simulating FCM token registration from Firebase Messaging
    _fcmToken = 'fcm_tok_${DateTime.now().millisecondsSinceEpoch}_production_demo';

    // 2. Default seeded notifications
    _notifications.addAll([
      AppNotification(
        id: 'notif_1',
        title: '🔥 Exclusive 30% Off Flash Sale!',
        body: 'Use code FLUTTER30 on electronics and trending fashion today.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        type: NotificationType.flashSale,
      ),
      AppNotification(
        id: 'notif_2',
        title: '📦 Order #8472 Dispatched',
        body: 'Your package is on its way via Express Delivery.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: NotificationType.orderUpdate,
      ),
      AppNotification(
        id: 'notif_3',
        title: '🔒 Security Alert',
        body: 'New sign-in detected from Android Client.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.security,
      ),
    ]);

    _initialized = true;
  }

  /// Handles incoming push payloads (both foreground and background)
  void handleIncomingMessage({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? payload,
  }) {
    final notification = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      data: payload,
    );

    _notifications.insert(0, notification);
    _notificationStreamController.add(notification);
  }

  /// Simulates subscribing to an FCM topic e.g. "flash_sales" or "order_tracking"
  Future<bool> subscribeToTopic(String topic) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  void dispose() {
    _notificationStreamController.close();
  }
}
