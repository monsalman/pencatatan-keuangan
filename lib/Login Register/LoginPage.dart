import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Page/HomePage.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _kontrollerEmail = TextEditingController();
  final _kontrollerKataSandi = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    try {
      final respon = await Supabase.instance.client.auth.signInWithPassword(
        email: _kontrollerEmail.text,
        password: _kontrollerKataSandi.text,
      );
      if (respon.user != null) {
        Navigator.push(context,MaterialPageRoute(builder: (context) => HomePage()),);
      }
    } catch (kesalahan) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan: ${kesalahan.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF252B48),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: screenHeight,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(context),
                SizedBox(height: screenHeight * 0.02),
                _buildTitle(),
                SizedBox(height: screenHeight * 0.05),
                _buildInputField('Email'),
                SizedBox(height: screenHeight * 0.02),
                _buildInputField('Password', isPassword: true),
                SizedBox(height: screenHeight * 0.05),
                _buildRegisterButton(),
                const Spacer(),
                _buildLoginPrompt(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.pushNamed(context, 'landingPage');
      },
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text(
        'Masuk',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInputField(String label, {bool isPassword = false}) {
    return TextField(
      controller: label == 'Email' ? _kontrollerEmail : _kontrollerKataSandi,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      cursorColor: WarnaSecondary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 16,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFEBF400)),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: WarnaSecondary,
          foregroundColor: WarnaUtama,
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          'Masuk',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum Punya Akun?',
          style: TextStyle(
            color: Color(0xFFEBF400),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, 'daftarPage');
          },
          child: const Text(
            'Daftar',
            style: TextStyle(
              color: Color(0xFF5786FF),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _kontrollerEmail.dispose();
    _kontrollerKataSandi.dispose();
    super.dispose();
  }
}