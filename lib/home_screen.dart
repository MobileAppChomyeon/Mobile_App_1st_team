import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'plantBook.dart';
import 'goalSetting.dart';
import 'weeklySleepData.dart';

// void main() {
//   runApp(const Directionality(
//       textDirection: TextDirection.ltr, child: HomeScreen()));
// }

class HomeScreen extends StatefulWidget {
  // final String plantNickname;

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? backgroundImage;
  String? flowerImage;
  String? plantName = '무리무리';
  String? sleepComment;
  final int totalSleepDuration = 8; // 총 경험치
  final int sleepScore = 10; // 오늘 수면 점수

  @override
  void initState() {
    super.initState();
    backgroundImage = 'assets/background/morning.png';
    flowerImage = 'assets/flower/daisy/daisy4.png';
    sleepComment = "어느정도 주무셨군요!\n오늘은 조금 더 일찍 잠에 들어 보세요";
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
          Align(
            alignment: Alignment.topCenter, // 수평 중앙, 상단 정렬
            child: Padding(
              padding: const EdgeInsets.only(top: 75), // 위쪽 간격
              child: PlantRoomName(
                plantName: plantName!,
              ),
            ),
          ),

          Positioned(
            top: 110, // 화면 위에서 100px 아래 위치
            left: 16,
            right: 16,
            child: Container(
              height: 23, // 전체 Progress Bar 높이
              decoration: BoxDecoration(
                color: const Color(0xffE4E4E4), // 전체 배경색 (회색)
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  // 흰색 테두리
                  color: Colors.white.withOpacity(0.8),
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
                        color: const Color(0xff8BC34A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // 연초록 바 (누적 경험치)
                  Container(
                    width: maxWidth * totalProgress, // 누적 경험치 비율만큼 너비 설정
                    decoration: BoxDecoration(
                      color: const Color(0xffC1E1C1), // 연초록색
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Positioned(
              bottom: 200,
              child: Image.asset(flowerImage!),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 수면 설정 버튼
                  VerticalIconButton(
                    iconName: "gear", // 설정 아이콘
                    label: '수면 설정',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoalSetting(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24), // 버튼 간 간격
                  // 수면 기록 버튼
                  VerticalIconButton(
                    iconName: "moon", // 수면 아이콘
                    label: '수면 기록',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Weekly(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24), // 버튼 간 간격
                  // 도감 버튼
                  VerticalIconButton(
                    iconName: "book", // 책 아이콘
                    label: '도감',
                    onPressed: () {
                      print("도감 버튼 클릭");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlantBook()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/dquote1.svg',
                      width: 10,
                      height: 10,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      sleepComment!,
                      style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    ),
                    SvgPicture.asset(
                      'assets/icons/dquote2.svg', // SVG 파일 경로
                      width: 10,
                      height: 10,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                SizedBox(height: 100)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class VerticalIconButton extends StatelessWidget {
  final String iconName;
  final String label;
  final VoidCallback onPressed;

  VerticalIconButton({
    required this.iconName,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/$iconName.svg', // SVG 파일 경로
            width: 24, // 아이콘 크기
            height: 24,
            color: Colors.black, // 아이콘 색상
          ),
          SizedBox(height: 2), // 아이콘과 텍스트 간격
          Text(
            label,
            style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class PlantRoomName extends StatelessWidget {
  final String plantName;

  const PlantRoomName({Key? key, required this.plantName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // 여백 설정
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // 배경 흰색
        borderRadius: BorderRadius.circular(10), // 모서리 반경
      ),
      child: Text(
        '$plantName 방', // 텍스트 내용
        style: const TextStyle(
          fontFamily: 'Pretendard', // Pretendard 폰트 사용
          fontSize: 16, // 폰트 크기
          fontWeight: FontWeight.w300, // Regular 두께
          color: Colors.black, // 텍스트 색상
        ),
      ),
    );
  }
}
