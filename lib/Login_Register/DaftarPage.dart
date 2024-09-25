import 'package:flutter/material.dart';

class DaftarPage extends StatelessWidget {
  const DaftarPage({Key? key}) : super(key: key);

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
                        const SizedBox(height: 40),
                        _buildInputField('Username'),
                        const SizedBox(height: 20),
                        _buildInputField('Email'),
                        const SizedBox(height: 20),
                        _buildInputField('Password', isPassword: true),
                        const SizedBox(height: 40),
                        _buildRegisterButton(),
                        const Spacer(),
                        _buildLoginPrompt(context),
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
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text(
        'Daftar',
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
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
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
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle registration
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEBF400),
          foregroundColor: const Color(0xFF332941),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: const Text(
          'Daftar',
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
          'Sudah Punya Akun?',
          style: TextStyle(
            color: Color(0xFFEBF400),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, 'loginPage');
          },
          child: const Text(
            'Masuk',
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