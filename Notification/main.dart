import 'package:flutter/material.dart';
import 'package:notifications/local_notification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.requestPermission();
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notifications',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Notification')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await NotificationService.showNotification(
              id: 0,
              title: 'Hello',
              body: 'This is a local notification.',
            );
          },
          child: const Text('Send Notification'),
        ),
      ),
    );
  }
}
