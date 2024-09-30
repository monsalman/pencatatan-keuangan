import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../main.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;

  // Define imgList here
  final List<String> imgList = [
    'assets/launcher.png',
    'assets/splashscreen.png',
    'assets/launcher.png',
  ];

  // Tambahkan daftar teks untuk setiap gambar
  final List<String> textList = [
    'Lorem ipsum dolor sit amet consectetur adipiscing elit',
    'Teks kedua untuk gambar kedua',
    'Teks ketiga untuk gambar ketiga',
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: Container(
        color: WarnaUtama,
        width: screenWidth,
        height: screenHeight,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildImageAndText(screenWidth, screenHeight),
              ),
              _buildDotIndicator(),
              SizedBox(height: screenHeight * 0.05),
              _buildRegisterButton(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.02),
              _buildLoginText(screenWidth),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageAndText(double screenWidth, double screenHeight) {
    double imageSize = screenWidth * 0.5;
    double fontSize = screenWidth * 0.04;
    int maxTextLength = 70; // Batasan maksimum karakter untuk teks

    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 1,
        enlargeCenterPage: true,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
        viewportFraction: 1.0,
        height: screenHeight * 0.7,
      ),
      items: imgList.asMap().entries.map((entry) {
        int index = entry.key;
        String item = entry.value;
        String displayText = textList[index].length > maxTextLength
            ? textList[index].substring(0, maxTextLength) + '...'
            : textList[index];
        
        return Container(
          width: screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                item,
                fit: BoxFit.contain,
                width: imageSize,
                height: imageSize,
              ),
              SizedBox(height: screenHeight * 0.05),
              Container(
                width: screenWidth * 0.8,
                child: Text(
                  displayText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index
                  ? WarnaSecondary
                  : Colors.white,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRegisterButton(double screenWidth, double screenHeight) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'daftarPage');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: WarnaSecondary,
        foregroundColor: WarnaUtama,
        minimumSize: Size(screenWidth * 0.8, screenHeight * 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text(
        'Daftar',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoginText(double screenWidth) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, 'loginPage');
        },
        child: Text(
          'Masuk',
          style: TextStyle(
            color: WarnaSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
