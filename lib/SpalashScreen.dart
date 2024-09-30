import 'package:flutter/material.dart';
import 'package:pencatatan_keuangan/Page/HomePage2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'Login Register/LandingPage.dart';
import 'Page/HomePage.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 5));
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage2()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: WarnaUtama,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/splashscreen.png', width: 220, height: 220),
              SizedBox(height: 5),
              Text(
                'Pencatatan Keuangan',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Futura',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
