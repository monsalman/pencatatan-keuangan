import 'package:flutter/material.dart';
import 'package:pencatatan_keuangan/Login%20Register/LandingPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/notification_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'Login Register/LoginPage.dart';
import 'Login Register/RegisterPage.dart';
import 'services/SpalashScreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inisialisasi MobileAds
    await MobileAds.instance.initialize();
    
    // Inisialisasi Notification Service
    final notificationService = NotificationService();
    await notificationService.init();
    
    // Tambahkan try-catch untuk Supabase initialization
    try {
      await Supabase.initialize(
        url: 'https://wzvuymvcmzamnjltsipi.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6dnV5bXZjbXphbW5qbHRzaXBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg0NTk5NjQsImV4cCI6MjA0NDAzNTk2NH0.OQrP0BluxleoHK0dv2JqdAhCiVIHU1BqeSKVaQbalOY',
      );
      print('Supabase initialized successfully');
    } catch (e) {
      print('Error initializing Supabase: $e');
    }
    
    // Setelah semua inisialisasi selesai
    await notificationService.showDailyReminder();
    
  } catch (e) {
    print('Error in initialization: $e');
  }

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