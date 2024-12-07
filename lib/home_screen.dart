import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:health/health.dart';
import 'package:mobileapp/plantSelect.dart';
import 'package:ntp/ntp.dart';
import 'plantBook.dart';
import 'goalSetting.dart';
import 'weeklySleepData.dart';
import 'plantSelectAgain.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileapp/userData.dart';
import 'package:mobileapp/sleep_analyzer.dart';
import 'sleepdata_fetcher.dart';

// void main() {
//   runApp(const Directionality(
//       textDirection: TextDirection.ltr, child: HomeScreen()));
// }

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
  final UserDataService dataService = UserDataService();
  Map<String, dynamic>? currentPlantData;
  bool _isAuthorized = false;
  String _sleepDataText = '데이터 로딩 중...';
  String? backgroundImage;
  String? plantImage;
  String? plantName = '무리무리';
  String? sleepComment;
  final int totalSleepDuration = 300; // 총 경험치
  final int sleepScore = 10; // 오늘 수면 점수

  DateTime currentTime = DateTime.now();

  void getCurrentTime() async {
    DateTime today = await NTP.now();
    setState(() {
      currentTime = today.toUtc().add(Duration(hours: 9));
    });
  }

  @override
  void initState() {
    super.initState();
    sleepComment = "어느정도 주무셨군요!\n오늘은 조금 더 일찍 잠에 들어 보세요";
    getCurrentTime();
    _initialize();
    _initializePlant();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && totalSleepDuration >= 100) {
        // 경험치 최대치되면!!
        _showPlantPopup();
      }
    });
  }

  void _showPlantPopup() {
    DateTime now = currentTime;
    int daysTaken = 30; // now.difference(startDate).inDays; // 걸린 날짜 계산

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 식물 이미지
              plantImage != null
                  ? Image.asset(
                      plantImage!,
                      width: 100,
                      height: 100,
                    )
                  : Center(child: CircularProgressIndicator()),
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
                  backgroundColor: const Color(0xFFB4C7E7), // 버튼 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "만나러가기",
                  style: TextStyle(
                    fontFamily: "Pretendard",
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _initializePlant() async {
    currentPlantData = await dataService.fetchCurrentPlantInfo();
    print("지금 키우는 식물 데이터");
    print(currentPlantData);

    if (currentPlantData != null) {
      String plantId = currentPlantData!['plantId'];
      String imageUrl = '';
      if (totalSleepDuration < 100) {
        imageUrl = 'assets/flower/$plantId/${plantId}1.png';
        dataService.savePlantInfo(growthStage: 1, imageUrl: imageUrl);
      } else if (totalSleepDuration < 300) {
        imageUrl = 'assets/flower/$plantId/${plantId}2.png';
        dataService.savePlantInfo(growthStage: 2, imageUrl: imageUrl);
      } else if (totalSleepDuration < 500) {
        imageUrl = 'assets/flower/$plantId/${plantId}3.png';
        dataService.savePlantInfo(growthStage: 3, imageUrl: imageUrl);
      } else {
        imageUrl = 'assets/flower/$plantId/${plantId}4.png';
        dataService.savePlantInfo(growthStage: 4, imageUrl: imageUrl);
      }
      plantName = currentPlantData!['nickname'];
      backgroundImage = currentPlantData!['backgroundImage'];
      plantImage = imageUrl;
    } else {
      plantName = '이름이 없어요';
      backgroundImage = 'assets/background/morning.png';
      plantImage = 'assets/flower/daisy/daisy4.png';
    }
  }

  void updateSleepData(DateTime startDate, List mockData) async {
    final userService = UserDataService();
    int duration = currentTime.difference(startDate).inDays;

    try {
      print("Duration (days): $duration");
      print("MockData length: ${mockData.length}");
      if (mockData.length < duration * 4) {
        print("Insufficient mock data! Exiting update.");
        return;
      }

      for (int i = 0; i < duration; i++) {
        final currentDate = startDate.add(Duration(days: i+1));
        final today = currentDate.toIso8601String().split('T')[0];
        var dayIndex = i;

        try {
          final rem = (mockData[dayIndex * 4 + 3].value as NumericHealthValue)
              .numericValue
              .toInt();
          final light = (mockData[dayIndex * 4 + 1].value as NumericHealthValue)
              .numericValue
              .toInt();
          final deep = (mockData[dayIndex * 4 + 2].value as NumericHealthValue)
              .numericValue
              .toInt();
          final total = (mockData[dayIndex * 4].value as NumericHealthValue)
              .numericValue
              .toInt();

          print("Saving data for day $dayIndex:");
          print("Sleep Start: ${mockData[dayIndex * 4].dateFrom}");
          print("Wake Up: ${mockData[dayIndex * 4].dateTo}");
          print("REM Sleep: $rem");
          print("Light Sleep: $light");
          print("Deep Sleep: $deep");
          print("Total Sleep Duration: $total");

          // Firestore 저장
          await userService.saveSleepInfo(
            date: today,
            sleepStartTime:
                mockData[dayIndex * 4].dateFrom.toIso8601String().split('T')[1],
            wakeUpTime:
                mockData[dayIndex * 4].dateTo.toIso8601String().split('T')[1],
            remSleep: rem,
            lightSleep: light,
            deepSleep: deep,
            totalSleepDuration: total,
            targetHours: 8,
            targetSleepTime: '오후 11시',
          );
        } catch (e) {
          print("Error processing data for day $dayIndex: $e");
        }
      }
      print('테스트 수면 데이터 저장 성공!');
    } catch (e) {
      print('Error saving mock sleep data: $e');
    }
  }

  Future<void> updateGoal(DateTime startDate) async {
    final userService = UserDataService();
    int duration = currentTime.difference(startDate).inDays;

    try {
      Map<String, dynamic>? lastKnownGoal;

      // 1. Goal 데이터를 채우기
      for (int i = 0; i <= duration; i++) {
        final currentDate = startDate.add(Duration(days: i+1));
        final today = currentDate.toIso8601String().split('T')[0];

        // GoalData 가져오기
        final GoalData = await userService.fetchGoal(date: today);

        if (GoalData != null) {
          // Goal 데이터가 존재하면 최신 데이터로 갱신
          lastKnownGoal = {
            'targetHours': GoalData['targetHours'] as int,
            'targetSleepTime': GoalData['targetSleepTime'] as String,
          };
        } else if (lastKnownGoal != null) {
          // Goal 데이터가 없고 마지막으로 알려진 Goal 데이터가 있으면 저장
          await userService.saveGoal(
            date: today,
            targetHours: lastKnownGoal['targetHours'] as int,
            targetSleepTime: lastKnownGoal['targetSleepTime'] as String,
          );
          print('$today: Goal 데이터를 이전 데이터로 채웠습니다.');
        } else {
          print('$today: Goal 데이터도 없고 이전 데이터도 없습니다. 기본값 사용.');
        }
      }

      // 2. SleepInfo 데이터를 업데이트
      for (int i = 0; i <= duration; i++) {
        final currentDate = startDate.add(Duration(days: i+1));
        final today = currentDate.toIso8601String().split('T')[0];

        final GoalData = await userService.fetchGoal(date: today);

        if (GoalData != null) {
          // SleepInfo에 Goal 데이터를 저장
          final targetHours = GoalData['targetHours'] as int?;
          final targetSleepTime = GoalData['targetSleepTime'] as String?;

          if (targetHours != null && targetSleepTime != null) {
            await userService.saveSleepInfo(
              date: today,
              targetHours: targetHours,
              targetSleepTime: targetSleepTime,
            );
            print('$today: SleepInfo 업데이트 완료.');
          } else {
            print('$today: Goal 데이터가 불완전하여 SleepInfo를 업데이트하지 못했습니다.');
          }
        } else {
          print('$today: Goal 데이터가 없어 SleepInfo를 업데이트하지 못했습니다.');
        }
      }

      print('Goal 및 SleepInfo 업데이트 완료!');
    } catch (e) {
      print('Error updating sleep goals and info: $e');
    }
  }

  Map<String, int> parseTime(String timeString) {
    final timeRegex = RegExp(r'(오전|오후)\s*(\d{1,2})시\s*(\d{1,2})?분?');
    final match = timeRegex.firstMatch(timeString);

    if (match == null) {
      throw FormatException('Invalid time format: $timeString');
    }

    final period = match.group(1); // '오전' 또는 '오후'
    final rawHour = int.parse(match.group(2)!); // 시
    final rawMinute = match.group(3) != null ? int.parse(match.group(3)!) : 0; // 분

    int hour = period == '오후' && rawHour != 12 ? rawHour + 12 : rawHour;
    hour = period == '오전' && rawHour == 12 ? 0 : hour;

    return {'hour': hour, 'minute': rawMinute};
  }



  void updateScore(DateTime startDate, List sleepDataList) async {
    final userService = UserDataService();
    int duration = currentTime.difference(startDate).inDays;
    try {
      print("Duration (days): $duration");
      print("SleepData length: ${sleepDataList.length}");
      if (sleepDataList.length < duration * 4) {
        print("Insufficient sleep data! Exiting update.");
        return;
      }

      for (int i = 0; i < duration; i++) {
        final currentDate = startDate.add(Duration(days: i+1));
        final today = currentDate.toIso8601String().split('T')[0];

        var dayIndex = i;

        int rem = (sleepDataList[dayIndex * 4 + 3].value as NumericHealthValue)
            .numericValue
            .toInt();
        int remHour = rem ~/ 60;
        int remMinute = rem % 60;

        final sleepData = SleepData(
          bedTime: sleepDataList[dayIndex * 4].dateFrom,
          wakeTime: sleepDataList[dayIndex * 4].dateTo,
          deepSleep: Duration(
              hours:
              (sleepDataList[dayIndex * 4 + 2].value as NumericHealthValue)
                  .numericValue
                  .toInt()), // 깊은 수면
          remSleep: Duration(hours: remHour, minutes: remMinute), // REM 수면
        );

        final GoalData = await userService.fetchGoal(date: today);
        if (GoalData == null) {
          print("Goal data is missing for $today. Skipping.");
          continue;
        }

        // parseTime 호출 후 결과값을 받아옵니다.
        final timeResult = parseTime(GoalData['targetSleepTime']);
        int sleepHour = timeResult['hour']!;
        int sleepMinute = timeResult['minute']!;

        final preferredBedTime = DateTime(
            currentDate.year, currentDate.month, currentDate.day - 1, sleepHour, sleepMinute);
        final preferredSleepTime = Duration(hours: GoalData['targetHours']);
        final preferredWakeTime = preferredBedTime.add(preferredSleepTime);

        print('목표 -> 취침시간: $preferredBedTime, 기상시간: $preferredWakeTime, 총 수면시간: $preferredSleepTime');

        final sleepAnalyzer = SleepAnalyzer(
          preferredBedTime: preferredBedTime,
          preferredSleepTime: preferredSleepTime,
          preferredWakeTime: preferredWakeTime,
        );

        final sleepScore = sleepAnalyzer.calculateSleepScore(sleepData);
        final qualities = sleepAnalyzer.evaluateSleepQuality(sleepData);

        await userService.saveSleepInfo(
          date: today,
          sleepScore: sleepScore,
          scheduleScore: qualities[0],
          durationScore: qualities[1],
          qualityScore: qualities[2],
        );
      }
      print('테스트 수면 점수 저장 성공!');
    } catch (e) {
      print('Error saving mock sleep data: $e');
    }
  }

  // TODO: mockdata 생성 오류 해결! (range 오류)
  // TODO: sleepScore 계산 오류 해결! (목표 시간 등은 제대로 받는 거 확인됨)

  Future<void> _initialize() async {
    bool isAuthorized = await _sleepDataFetcher.requestPermissions();

    setState(() {
      _isAuthorized = isAuthorized;
      dataService.updateMockEncyclopedia();
    });

    if (isAuthorized) {
      final now = currentTime;
      final oneWeekAgo = now.subtract(const Duration(days: 7)); //days 수정 가능
      final sleepData = await _sleepDataFetcher.fetchSleepData(oneWeekAgo, now);
      updateSleepData(oneWeekAgo, sleepData);
      updateGoal(oneWeekAgo);
      updateScore(oneWeekAgo, sleepData);

      setState(() {
        if (sleepData.isEmpty) {
          _sleepDataText = '수면 데이터가 없습니다';
        } else {
          print('수면 데이터: $sleepData'); // 디버깅용 로그
          _sleepDataText = '11';
          // sleepData
          // .map((data) =>
          //     '${data.type} ${data.dateFrom.month}/${data.dateFrom.day}${data.dateFrom.hour}:${data.dateFrom.minute} - ${data.dateTo.month}/${data.dateTo.day}${data.dateTo.hour}:${data.dateTo.minute}')
          // .join('\n');
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
            child: backgroundImage != null
                ? Image.asset(
                    backgroundImage!,
                    fit: BoxFit.cover,
                  )
                : Center(child: CircularProgressIndicator()),
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
              child: plantImage != null
                  ? Image.asset(
                      plantImage!,
                      fit: BoxFit.fitWidth, // 가로 크기에 맞춰서 비율 유지
                    )
                  : Center(child: CircularProgressIndicator()),
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
