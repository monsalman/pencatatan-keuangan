import 'package:flutter/material.dart';
import 'package:pencatatan_keuangan/Page/HomePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login berhasil!',
              style: TextStyle(color: WarnaUtama),
            ),
            backgroundColor: WarnaSecondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        throw Exception('Login gagal');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252B48),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBackButton(context),
                        const SizedBox(height: 20),
                        _buildTitle(),
                        const SizedBox(height: 20),
                        _buildInputField('Email', _emailController),
                        const SizedBox(height: 20),
                        _buildInputField('Password', _passwordController, isPassword: true),
                        const SizedBox(height: 40),
                        _buildLoginButton(),
                        const Spacer(),
                        _buildRegisterPrompt(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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

  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
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
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEBF400),
          foregroundColor: WarnaUtama,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(WarnaUtama),
                ),
              )
            : const Text(
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

  Widget _buildRegisterPrompt(BuildContext context) {
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
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
}