import 'package:flutter/material.dart';
import 'package:pencatatan_keuangan/Login%20Register/LandingPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

import 'Login Register/LoginPage.dart';
import 'Login Register/RegisterPage.dart';
import 'SpalashScreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi notifikasi
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.showDailyReminder();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://yxanyfzuxjrwzvdnzxud.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4YW55Znp1eGpyd3p2ZG56eHVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY4NTYxNTQsImV4cCI6MjA0MjQzMjE1NH0.vlAGUp1dTk8quU77vAThNnHKtIzBGLAiR0rC1eLlSsM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        'daftarPage': (context) => RegisterPage(),
        'loginPage': (context) => LoginPage(),
        'landingPage': (context) => LandingPage()
      },
      theme: ThemeData(
        primaryColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
    );
  }
}

final Color WarnaUtama = Color(0xFF252B48);
final Color WarnaSecondary = Color(0xFFEBF400);
// 0xFF332941
// arrow_up_right
// arrow_down_right

// Buat klien Supabase
final supabase = Supabase.instance.client;