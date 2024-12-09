import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'piechart.dart';
import 'userData.dart';

class Daily extends StatefulWidget {
  final String? chosen; // chosen 값을 전달받음

  Daily({
    Key? key,
    required this.chosen,
  }) : super(key: key);

  @override
  State<Daily> createState() => _DailyState();
}

class _DailyState extends State<Daily> {
  String month = '';
  String day = '';

  String sleepStartTime = 'no data';
  String wakeupTime = 'no data';
  int remSleep = 0;
  int lightSleep = 0;
  int deepSleep = 0;
  int totalSleepDuration = 0;
  int sleepScore = 0;
  String durationScore = 'null';
  String qualityScore = 'null';
  String scheduleScore = 'null';
  String message = '';
  late Future<void> _loadingFuture;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void setDate(String date) {
    List<String> dateParts = date.split('-');

    if (dateParts.length == 3) {
      month = dateParts[1]; // 'MM' 부분 추출
      int dayInt = int.parse(dateParts[2]); // 'dd' 부분 추출
      day = dayInt.toString();
    } else {
      print('Invalid date format');
    }
  }

  @override
  void initState() {
    super.initState();
    setDate(widget.chosen!);
    _loadingFuture = loadDailySleepData();
  }

  String convertToAMPM(String time) {
    time = time.split('Z')[0];
    time = time.replaceAll(RegExp(r'\.\d+$'), '');

    List<String> hourMinuteParts = time.split(':');

    if (hourMinuteParts.length != 3) {
      throw FormatException("Invalid time format");
    }

    int hour = int.parse(hourMinuteParts[0].trim());
    String minute = hourMinuteParts[1].trim();

    // PM/AM 구분
    String period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    return '${hour}:$minute $period';
  }

  int calculateDuration(String startTime, String endTime) {
    DateTime parseTime(String time, bool isPM) {
      List<String> parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      return DateTime(0, 1, 1, hour, minute);
    }

    bool isStartPM = startTime.contains('PM');
    bool isEndPM = endTime.contains('PM');

    DateTime start = parseTime(
        startTime.replaceAll(RegExp(r'[APap][Mm]'), '').trim(), isStartPM);
    DateTime end = parseTime(
        endTime.replaceAll(RegExp(r'[APap][Mm]'), '').trim(), isEndPM);

    if (end.isBefore(start)) end = end.add(Duration(days: 1));

    Duration difference = end.difference(start);
    return difference.inMinutes;
  }

  Future<void> loadDailySleepData() async {
    final userService = UserDataService();

    try {
      final sleepInfo = await userService.fetchSleepInfo(date: widget.chosen!);
      if (sleepInfo != null) {
        print('Loaded Sleep Data!'); // 로그 추가
        if (mounted) {
          setState(() {
            deepSleep = sleepInfo['deepSleep'] ?? deepSleep;
            sleepScore = sleepInfo['sleepScore'] ?? sleepScore;
            lightSleep = sleepInfo['lightSleep'] ?? lightSleep;
            remSleep = sleepInfo['remSleep'] ?? remSleep;
            sleepStartTime = sleepInfo['sleepStartTime'] ?? sleepStartTime;
            totalSleepDuration =
                sleepInfo['totalSleepDuration'] ?? totalSleepDuration;
            wakeupTime = sleepInfo['wakeUpTime'] ?? wakeupTime;
            durationScore =
                sleepInfo['qualities']['durationScore'] ?? durationScore;
            qualityScore =
                sleepInfo['qualities']['qualityScore'] ?? qualityScore;
            scheduleScore =
                sleepInfo['qualities']['scheduleScore'] ?? scheduleScore;

            print('SleepStartTime (before convert): $sleepStartTime');
            print('WakeUpTime (before convert): $wakeupTime');

            // 데이터를 로드한 후에 AM/PM 변환
            sleepStartTime = convertToAMPM(sleepStartTime);
            wakeupTime = convertToAMPM(wakeupTime);

            print('SleepStartTime (after convert): $sleepStartTime');
            print('WakeUpTime (after convert): $wakeupTime');

            message = getSleepFeedback(sleepScore);
          });
        }
      } else {
        print('No sleep info found for the given date.');
      }
    } catch (e) {
      print('Error loading sleep goal: $e');
    }
  }

  String getSleepFeedback(int score) {
    if (score >= 90) {
      return "완벽한 수면이에요!\n최고의 컨디션이겠어요. 😊";
    } else if (score >= 80) {
      return "잘 주무셨네요!\n상쾌한 하루 되세요. ✨";
    } else if (score >= 70) {
      return "괜찮은 수면이었어요.\n조금 더 신경 쓰면 더 좋아질 거예요. 💪";
    } else if (score >= 60) {
      return "수면 패턴이 불규칙해요.\n일정한 시간에 자고 일어나보세요. 🌙";
    } else if (score >= 50) {
      return "수면의 질이 좋지 않아요.\n취침 전 루틴을 만들어보는 건 어떨까요? 💭";
    } else {
      return "수면 관리가 필요해요.\n규칙적인 수면 습관을 만들어보세요. 😴";
    }
  }

  Map<String, int> minToHour(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return {
      'hours': hours,
      'minutes': minutes,
    };
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xffEDF2F7),
      appBar: AppBar(
        backgroundColor: Color(0xffEDF2F7),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: Text(
          "수면 기록",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (context, snapshot) {
          /*if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('에러: ${snapshot.error}');
          }

          if (snapshot.hasData) {
            return Text("데이터 로드 완료");
          }*/
          return Padding(
            padding: EdgeInsets.fromLTRB(size.width * 0.08, size.height * 0.01,
                size.width * 0.08, size.height * 0.01),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${month}월 ${day}일의 수면 기록",
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 19),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.41,
                        height: size.height * 0.37,
                        padding: EdgeInsets.all(size.height * 0.03),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("수면 경험치",
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                            SizedBox(height: size.height * 0.01),
                            Container(
                              child: CustomPaint(
                                // CustomPaint를 그리고 이 안에 차트를 그려줍니다..
                                size: Size(
                                  size.width * 0.25,
                                  size.width * 0.25,
                                ), // CustomPaint의 크기는 가로 세로 150, 150으로 합니다.
                                painter: PieChart(
                                  percentage:
                                      sleepScore, // 파이 차트가 얼마나 칠해져 있는지 정하는 변수입니다.
                                  textScaleFactor: 0.8,
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "잠든 시간",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          textAlign: TextAlign.right,
                                        ),
                                        Text(
                                          "총 수면 시간",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          textAlign: TextAlign.right,
                                        ),
                                        Text(
                                          "수면의 질",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          textAlign: TextAlign.right,
                                        ),
                                      ]),
                                  SizedBox(width: 5),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          scheduleScore,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        Text(
                                          durationScore,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        Text(
                                          qualityScore,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ]),
                                ])
                          ],
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xffA3BFD9).withOpacity(0.6),
                              Color(0xffC1E1C1).withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.02,
                      ),
                      Container(
                        width: size.width * 0.41,
                        height: size.height * 0.37,
                        padding: EdgeInsets.all(size.height * 0.03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "수면 시간",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: size.height * 0.02),
                            Padding(
                              padding: EdgeInsets.only(left: size.width * 0.01),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "잠든 시간",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(sleepStartTime,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24)),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    "깬 시간",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(wakeupTime,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24)),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    "총 수면 시간",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                      "${minToHour(totalSleepDuration)['hours']}H ${minToHour(totalSleepDuration)['minutes']}M",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24)),
                                ],
                              ),
                            )
                          ],
                        ),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  Container(
                    width: size.width * 0.84,
                    height: size.height * 0.21,
                    padding: EdgeInsets.fromLTRB(
                        size.width * 0.06,
                        size.height * 0.03,
                        size.width * 0.06,
                        size.height * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "수면의 질",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: size.height * 0.02),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "렘수면",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    "${minToHour(remSleep)['hours']}H ${minToHour(remSleep)['minutes']}M",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "얕은 수면",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    "${minToHour(lightSleep)['hours']}H ${minToHour(lightSleep)['minutes']}M",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "깊은 수면",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    "${minToHour(deepSleep)['hours']}H ${minToHour(deepSleep)['minutes']}M",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text(
                    "이날의 메시지",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: size.height * 0.03),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            width: size.width * 0.04,
                            height: size.height * 0.02,
                            child:
                                SvgPicture.asset('assets/icons/dquote1.svg')),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        Container(
                            width: size.width * 0.04,
                            height: size.height * 0.02,
                            child:
                                SvgPicture.asset('assets/icons/dquote2.svg')),
                      ])
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
