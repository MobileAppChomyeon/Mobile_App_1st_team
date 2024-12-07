import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntp/ntp.dart';
import 'daySleepData.dart';
import 'package:intl/intl.dart';
import 'userData.dart';
import 'sleep_analyzer.dart';

class Weekly extends StatefulWidget {
  const Weekly({super.key});

  // final String title;

  void check_time(BuildContext context){ //context는 Snackbar용, 다른 방식으로 출력할거면 필요없음.
    var now = new DateTime.now(); //반드시 다른 함수에서 해야함, Mypage같은 클래스에서는 사용 불가능
    String formatDate = DateFormat('yy/MM/dd - HH:mm:ss').format(now); //format변경
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar( //출력용 snackbar
          content: Text('$formatDate'),
          duration: Duration(seconds: 20),
        )
    );
  }


  @override
  State<Weekly> createState() => _WeeklyState();
}

class _WeeklyState extends State<Weekly> {

  int todaySleepScore = 0;
  String message = '';
  DateTime? startDate;
  List<Map<String, dynamic>> experienceDateList = []; // 날짜와 경험치 리스트
  DateTime todayDate = DateTime.now();
  String today = '';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool isLoading = true;

  void getCurrentTime() async {
    DateTime currentDate = await NTP.now();
    setState(() {
      todayDate = currentDate.toUtc().add(Duration(hours: 9));
      today = todayDate.toIso8601String().split('T')[0];
    });
  }

  void loadTodaySleepData() async {
    getCurrentTime();
    final userService = UserDataService();
    try {
      final sleepInfo = await userService.fetchSleepInfo(date: today);
      if (sleepInfo?['sleepScore'] == null) {
        print('No sleep info found for the first given date.');
        DateTime currentDate = await NTP.now();
        setState(() {
          todayDate = currentDate.toUtc().subtract(Duration(hours: 15));
          today = todayDate.toIso8601String().split('T')[0];
        });
        final sleepInfo = await userService.fetchSleepInfo(date: today);
        if (mounted) {
          setState(() {
            todaySleepScore = sleepInfo?['sleepScore'] ?? todaySleepScore;
            message = getSleepFeedback(todaySleepScore);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            todaySleepScore = sleepInfo?['sleepScore'] ?? todaySleepScore;
            message = getSleepFeedback(todaySleepScore);
          });
        }
      }
    } catch (e) {
      print('Error loading sleep goal: $e');
    }
  }

  Future<void> loadStartDateAndExperiences() async {
    final userService = UserDataService();
    try {
      // StartDate 가져오기
      final dateInfo = await userService.fetchCurrentPlantInfo();
      if (dateInfo != null) {
        DateTime? fetchedStartDate = (dateInfo['startDate'] as Timestamp).toDate();
        if (fetchedStartDate != null) {
          List<Map<String, dynamic>> dateExperienceList =
          await generateDateExperienceList(fetchedStartDate);
          setState(() {
            startDate = fetchedStartDate;
            experienceDateList = dateExperienceList;
          });
        }
      } else {
        print('No start date found.');
      }
    } catch (e) {
      print('Error loading start date: $e');
    }
  }


  // TODO: 아오 여기 수정
  Future<void> loadMockDateAndExperiences(DateTime fetchedStartDate) async {
    final userService = UserDataService();
    try {
      List<Map<String, dynamic>> dateExperienceList =
      await generateDateExperienceList(fetchedStartDate);
      setState(() {
        startDate = fetchedStartDate;
        experienceDateList = dateExperienceList;
      });
    } catch (e) {
      print('Error loading start date: $e');
    }
  }



  Future<List<Map<String, dynamic>>> generateDateExperienceList(DateTime fetchedStartDate) async {
    final userService = UserDataService();
    List<Map<String, dynamic>> dateSleepScoreList = [];
    DateTime currentDate = fetchedStartDate;

    while (!currentDate.isAfter(todayDate)) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
      try {
        final sleepInfo = await userService.fetchSleepInfo(date: formattedDate);
        int sleepScore = sleepInfo?['sleepScore'] ?? 0;

        dateSleepScoreList.add({
          'date': formattedDate,
          'experience': sleepScore, // 'experience' 키로 저장
        });
      } catch (e) {
        print('Error fetching sleepScore for $formattedDate: $e');
        dateSleepScoreList.add({
          'date': formattedDate,
          'experience': 0, // 오류 발생 시 기본값 0
        });
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    dateSleepScoreList.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return dateSleepScoreList;
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

  @override
  void initState() {
    super.initState();
    loadTodaySleepData();
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    loadTodaySleepData();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            }, icon: const Icon(Icons.arrow_back_ios)),
        title: const Text(
            '수면 기록',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: loadMockDateAndExperiences(DateTime.now().subtract(const Duration(days: 7))),
        builder: (context, snapshot) {
          /*if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()
                );
          }

          if (snapshot.hasError) {
            return Text('에러: ${snapshot.error}');
          }

          if (snapshot.hasData) {
            return Text("데이터 로드 완료");
          }*/
        return Padding(
          padding: EdgeInsets.fromLTRB(size.width * 0.08, size.height * 0.04, size.width * 0.08, size.height * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("오늘의 수면 경험치",
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 19)
              ),
              SizedBox(
                  height: size.height * 0.02
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                        return Daily(
                          chosen: today,
                        );
                      }));
                },
                child: Container(
                  width: size.width * 0.84,
                  height: size.height * 0.15,
                  child: Row(
                    children: [
                      SizedBox(
                          width:35
                      ),
                      Text('${todaySleepScore}', style:
                      TextStyle(fontWeight: FontWeight.w500,fontSize: 40),
                        textAlign: TextAlign.right,),
                      SizedBox(
                          width:20
                      ),
                      Text('${message}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                          width: size.width * 0.04
                      ),
                      Icon(Icons.chevron_right, size: 14),
                    ],
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xffA3BFD9),
                        Color(0xffC1E1C1),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Text("지난날의 수면 경험치들",
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 19)
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Container(
                width: size.width * 0.84,
                height: size.height * 0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xffA3BFD9).withOpacity(0.2),
                ),
                padding: EdgeInsets.fromLTRB(size.width * 0.06, size.height * 0.02, size.width * 0.06, size.height * 0.02),
                child: ListView.builder(
                  itemCount: experienceDateList.length,
                  itemBuilder: (context, index) {
                    final item = experienceDateList[index];

                    return ListTile(
                      title: Text('${item['date']}: ${item['experience']} 경험치',
                          style: Theme.of(context).textTheme.bodyMedium),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return Daily(
                                chosen: item['date'],
                              );
                            }));
                      },
                      trailing: Icon(Icons.chevron_right, size: 16),
                    );
                  },
                ),
              ),
            ],
          ),
        );},
      ),
    );
  }
}



/* 추가 수정 포인트
* - 수면 경험치 어디서 어떻게 전달 받을 지
* - Daily 넘어갈 때 날짜 말고 어떤 거 전달해줄 지 (날짜에 따른 데이터 어떻게 전달 받을 지)
* - Daily에서 수면의 질 좋고 나쁨의 기준 어떻게 할 지
* - message 어떻게 출력할 지
* */