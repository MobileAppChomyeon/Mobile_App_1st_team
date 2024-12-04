import 'package:flutter/material.dart';
import 'package:mobileapp/home_screen.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BackgroundSelectPage extends StatefulWidget {
  final String plantNickname;

  const BackgroundSelectPage({super.key, required this.plantNickname});

  @override
  State<BackgroundSelectPage> createState() => _BackgroundSelectPageState();
}

class _BackgroundSelectPageState extends State<BackgroundSelectPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _backgroundData = [
    {
      'image': 'assets/background/morning.png',
      'title': '파랑새가 찾아온 아침',
    },
    {
      'image': 'assets/background/lunch.png',
      'title': '커튼을 걷고 맞이하는 점심',
    },
    {
      'image': 'assets/background/night.png',
      'title': '고요하고 반짝이는 밤',
    },
  ];

  Future<void> _saveBackgroundToFirestore(String backgroundImage) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인이 필요합니다.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Plants')
          .doc('currentPlant')
          .update({'backgroundImage': backgroundImage});

      print('배경 이미지 저장 완료: $backgroundImage');
    } catch (e) {
      print('배경 이미지 저장 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("배경 이미지 저장 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '식물 선택',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 이미지 배경과 상단 텍스트 및 버튼
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _backgroundData.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // 배경 이미지
                  Container(
                    margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        _backgroundData[index]['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),

                  // 이미지 제목


                ],
              );
            },
          ),
          // 상단 텍스트
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Text(
              '${widget.plantNickname}와 함께할 방을 골라주세요',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // 좌우 화살표 버튼
          Positioned(
            top: 0,
            bottom: 0,
            left: 10,
            child: IconButton(
              onPressed: _currentPage > 0
                  ? () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
                  : null,
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 10,
            child: IconButton(
              onPressed: _currentPage < _backgroundData.length - 1
                  ? () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
                  : null,
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Text(
              _backgroundData[_currentPage]['title']!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // 선택하기 버튼
          Positioned(
            bottom: 50,
            left: 50,
            right: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6FA5),
                minimumSize: const Size(320, 60),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 18,),
              ),
              onPressed: () async {
                final selectedBackground = _backgroundData[_currentPage];
                final backgroundImage = selectedBackground['image']!;

                // Firestore에 저장
                await _saveBackgroundToFirestore(backgroundImage);

                // HomeScreen으로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: const Text(
                '선택하기',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
