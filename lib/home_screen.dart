import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobileapp/plantSelect.dart';
import 'plantBook.dart';
import 'goalSetting.dart';
import 'weeklySleepData.dart';
import 'plantSelectAgain.dart';

// void main() {
//   runApp(const Directionality(
//       textDirection: TextDirection.ltr, child: HomeScreen()));
// }
import 'sleepdata_fetcher.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, // 디버그 배너 제거 (선택 사항)
    home: HomeScreen(),
  ));
}

//void main() {
//  runApp(const Directionality(
//      textDirection: TextDirection.ltr, child: HomeScreen()));
//}

class HomeScreen extends StatefulWidget {
  // final String plantNickname;

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SleepDataFetcher _sleepDataFetcher = SleepDataFetcher();
  bool _isAuthorized = false;
  String _sleepDataText = '데이터 로딩 중...';

  String? backgroundImage;
  String? plantImage;
  String? plantName = '무리무리';
  String? sleepComment;
  final int totalSleepDuration = 8; // 총 경험치
  final int sleepScore = 10; // 오늘 수면 점수

  @override
  void initState() {
    super.initState();
    backgroundImage = 'assets/background/morning.png';
    plantImage = 'assets/flower/daisy/daisy4.png';
    sleepComment = "어느정도 주무셨군요!\n오늘은 조금 더 일찍 잠에 들어 보세요";
    _initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && totalSleepDuration >= 1.0) {
        // 경험치 최대치되면!!
        _showPlantPopup();
      }
    });
  }

  void _showPlantPopup() {
    DateTime now = DateTime.now();
    int daysTaken = 30; // now.difference(startDate).inDays; // 걸린 날짜 계산

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 식물 이미지
              Image.asset(
                plantImage!,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              // 메시지
              Text(
                "식물이 다 자랐어요!",
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "$plantName(을/를) 다 키우는데\n총 $daysTaken일이 걸렸어요\n잘 키워줘서 고마워요",
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "다음 식물을 만나러 갈까요?",
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // 만나러가기 버튼
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 팝업 닫기
                  print("다음 페이지로 이동!");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlantSelectAgain(),
                    ),
                  ); // 다른 화면으로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6FA5), // 버튼 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "만나러가기",
                  style: TextStyle(
                    fontFamily: "Pretendard",
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _initialize() async {
    bool isAuthorized = await _sleepDataFetcher.requestPermissions();

    setState(() {
      _isAuthorized = isAuthorized;
    });

    if (isAuthorized) {
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final sleepData = await _sleepDataFetcher.fetchSleepData(oneWeekAgo, now);

      setState(() {
        if (sleepData.isEmpty) {
          _sleepDataText = '수면 데이터가 없습니다';
        } else {
          print('수면 데이터: $sleepData'); // 디버깅용 로그
          _sleepDataText = sleepData
              .map((data) =>
                  '${data.type} ${data.dateFrom.month}/${data.dateFrom.day}${data.dateFrom.hour}:${data.dateFrom.minute} - ${data.dateTo.month}/${data.dateTo.day}${data.dateTo.hour}:${data.dateTo.minute}')
              .join('\n');
        }
      });
    }
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
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width, // 화면 가로 크기
              child: Image.asset(
                plantImage!,
                fit: BoxFit.fitWidth, // 가로 크기에 맞춰서 비율 유지
              ),
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
                  const SizedBox(height: 24), // 버튼 간 간격
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
                  const SizedBox(height: 24), // 버튼 간 간격
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
                      _isAuthorized ? _sleepDataText : "권한 허용 필요",
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
                const SizedBox(height: 100)
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

  const VerticalIconButton({
    super.key,
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
          const SizedBox(height: 2), // 아이콘과 텍스트 간격
          Text(
            label,
            style: const TextStyle(
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

  const PlantRoomName({super.key, required this.plantName});

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
