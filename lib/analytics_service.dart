import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics =
      FirebaseAnalytics.instance;

  static Future<void> goalCreated() async {
    await _analytics.logEvent(
      name: 'goal_created',
    );
  }

  static Future<void> goalEdited() async {
    await _analytics.logEvent(
      name: 'goal_edited',
    );
  }

  static Future<void> goalDeleted() async {
    await _analytics.logEvent(
      name: 'goal_deleted',
    );
  }

  static Future<void> notificationEnabled() async {
    await _analytics.logEvent(
      name: 'notification_enabled',
    );
  }

  static Future<void> notificationDisabled() async {
    await _analytics.logEvent(
      name: 'notification_disabled',
    );
  }

  // Keep your existing habit analytics methods here as well.
}