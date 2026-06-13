// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

// Global notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://klwvscymnspnzxvgbkoc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtsd3ZzY3ltbnNwbnp4dmdia29jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzNjMxODIsImV4cCI6MjA3MzkzOTE4Mn0.M5Is7tN0VPvpmKtFCyw2yGF0icYls1xhfJWUnxqDTPU',
  );

  // Initialize timezone for scheduling
  tz.initializeTimeZones();

  // Configure notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entebbe Health Centre Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

/// Schedules a daily wellness notification at 10 AM
/// Schedules a daily wellness notification at 10 AM
Future<void> scheduleDailyNotification() async {
  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Health Tip',
      'Stay hydrated!',
      _nextInstanceOfTenAM(),   // ✅ use helper function
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Notifications',
          channelDescription: 'Daily health tips',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  } catch (e) {
    debugPrint("Notification scheduling failed: $e");
  }
}

/// Helper to calculate next 10 AM
tz.TZDateTime _nextInstanceOfTenAM() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}
