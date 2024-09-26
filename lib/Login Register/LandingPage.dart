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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                color: WarnaUtama,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildImageAndText(constraints),
                    _buildDotIndicator(),
                    _buildRegisterButton(constraints),
                    _buildLoginText(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageAndText(BoxConstraints constraints) {
    double maxWidth = constraints.maxWidth;
    double maxHeight = constraints.maxHeight;
    double imageSize = maxWidth * 0.6; // Increased size
    double fontSize = maxWidth * 0.04; // Adjusted font size

    return Container(
      height: maxHeight * 0.6,
      width: maxWidth,
      child: CarouselSlider(
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
        ),
        items: imgList.asMap().entries.map((entry) {
          int index = entry.key;
          String item = entry.value;
          return Container(
            width: maxWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  item,
                  fit: BoxFit.contain,
                  width: imageSize,
                  height: imageSize,
                ),
                SizedBox(height: maxHeight * 0.02),
                Text(
                  textList[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
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

  Widget _buildRegisterButton(BoxConstraints constraints) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'daftarPage');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: WarnaSecondary,
        foregroundColor: WarnaUtama,
        minimumSize: Size(constraints.maxWidth * 0.8, constraints.maxHeight * 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text(
        'Daftar',
        style: TextStyle(
          fontSize: constraints.maxWidth * 0.05,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoginText() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, 'loginPage');
        },
        child: Text(
          'Masuk',
          style: TextStyle(
            color: WarnaSecondary,  // Assuming you've set up the constants as suggested earlier
            fontSize: MediaQuery.of(context).size.width * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
