import 'package:flutter/material.dart';

void main() {
  runApp(const Directionality(
      textDirection: TextDirection.ltr, child: HomeScreen()));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? backgroundImage = 'assets/background/lunch.png';
  final int totalSleepDuration = 8; // 총 경험치
  final int sleepScore = 10; // 오늘 수면 점수

  @override
  void initState() {
    super.initState();
    backgroundImage = 'assets/background/lunch.png';
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Progress Bar 비율 계산, 레벨 나누기
    final double totalProgress =
        (totalSleepDuration / 100).clamp(0.0, 1.0); // 0~1 범위로 제한
    final double todayProgress =
        (sleepScore / 100).clamp(0.0, 1.0); // 0~1 범위로 제한
    final double maxWidth = MediaQuery.of(context).size.width - 32; // 좌우 여백 적용

    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              backgroundImage!,
              fit: BoxFit.cover,
            ),
          ),
          // Progress Bar
          Positioned(
            top: 100, // 화면 위에서 100px 아래 위치
            left: 16,
            right: 16,
            child: Container(
              height: 23, // 전체 Progress Bar 높이
              decoration: BoxDecoration(
                color: Color(0xffE4E4E4), // 전체 배경색 (회색)
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  // 흰색 테두리
                  color: Colors.white,
                  width: 4.0,
                ),
              ),
              child: Stack(
                children: [
                  // 진초록 바 (오늘 경험치)
                  Positioned(
                    child: Container(
                      width: maxWidth *
                          (todayProgress + totalProgress), // 오늘 경험치 비율만큼 너비 설정
                      height: 20, // 높이 유지
                      decoration: BoxDecoration(
                        color: Color(0xff8BC34A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // 연초록 바 (누적 경험치)
                  Container(
                    width: maxWidth * totalProgress, // 누적 경험치 비율만큼 너비 설정
                    decoration: BoxDecoration(
                      color: Color(0xffC1E1C1), // 연초록색
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
