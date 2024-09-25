import 'package:flutter/material.dart';
import 'package:pencatatan_keuangan/Login_Register/LoginPage.dart';
import 'package:pencatatan_keuangan/SpalashScreen.dart';
import 'package:pencatatan_keuangan/Login_Register/DaftarPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        'daftarPage': (context) => DaftarPage(),
        'loginPage': (context) => Loginpage(),
      },
      theme: ThemeData(
        primaryColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white ),
        useMaterial3: true,
      ),
    );
  }
}

final Color WarnaUtama = Color.fromARGB(255, 158, 203, 238);

// arrow_up_right
// arrow_down_right

// Buat klien Supabase
final supabase = Supabase.instance.client;