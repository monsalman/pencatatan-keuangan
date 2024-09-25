import 'package:flutter/material.dart';

import 'Login_Register/LandingPage.dart';
// import 'main.dart';

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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LandingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF252B48),
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
