import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;

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
          if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
            return Container(); // Mengembalikan container kosong jika tidak ada ukuran
          }
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  color: Color(0xFF252B48),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.05),
                        _buildImageAndText(constraints),
                        SizedBox(height: constraints.maxHeight * 0.05),
                        _buildDotIndicator(),
                        SizedBox(height: constraints.maxHeight * 0.05),
                        _buildRegisterButton(constraints),
                        SizedBox(height: constraints.maxHeight * 0.025),
                        _buildLoginText(),
                        SizedBox(height: constraints.maxHeight * 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageAndText(BoxConstraints constraints) {
    double imageSize = constraints.maxWidth * 0.7;
    double fontSize = constraints.maxWidth * 0.04;
    final List<String> imgList = [
      "assets/launcher.png",
      "assets/splashscreen.png",
      "assets/launcher3.png",
    ];

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 1.0,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            viewportFraction: 0.8,
            height: constraints.maxHeight * 0.5,
          ),
          items: imgList.asMap().entries.map((entry) {
            int index = entry.key;
            String item = entry.value;
            return Container(
              child: Column(
                children: [
                  Image.asset(
                    item,
                    fit: BoxFit.contain,
                    width: imageSize,
                    height: imageSize,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  Text(
                    textList[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontFamily: 'Futura',
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
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
                  ? const Color(0xFFEBF400)
                  : const Color(0xFFD9D9D9),
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
        backgroundColor: const Color(0xFFEBF400),
        foregroundColor: const Color(0xFF332941),
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'loginPage');
      },
      child: Text(
        'Masuk',
        style: TextStyle(
          color: Color(0xFFEBF400),
          fontSize: MediaQuery.of(context).size.width * 0.05,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
