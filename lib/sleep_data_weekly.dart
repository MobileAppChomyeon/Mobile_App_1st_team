import 'package:flutter/material.dart';
import 'sleep_data_day.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chomyeon Sleep Data',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        textTheme: TextTheme(
          titleMedium: TextStyle(
            color: Colors.black,
            fontFamily: "Pretendard",
            fontSize: 20,
            fontWeight: FontWeight.w600
          ),
          bodyLarge: TextStyle(
            color : Colors.black,
            fontFamily: "Pretendard",
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: TextStyle(
            color : Colors.black,
            fontFamily: "Pretendard",
            fontSize: 14,
            fontWeight: FontWeight.w300,
            height: 1.19,
          ),
        ),
        fontFamily: "Pretendard",
      ),
      home: Weekly(title: '수면 기록'),
    );
  }
}

class Weekly extends StatefulWidget {
  Weekly({super.key, required this.title});

  final String title;

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

  int experinecePoints = 60;
  String message = '어느 정도 주무셨군요!\n오늘은 조금 더 일찍 잠 들어 보세요';

  // 주어진 시작 날짜를 입력받아 오늘까지의 날짜 목록을 생성하는 함수
  List<DateTime> generateDateList(DateTime startDate) {
    List<DateTime> dateList = [];
    DateTime currentDate = startDate;

    while (!currentDate.isAfter(DateTime.now())) {
      dateList.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1)); // 하루씩 추가
    }

    return dateList.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    DateTime startDate = DateTime(2024, 10, 31);
    List<DateTime> dateList = generateDateList(startDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(widget.title,
            style: Theme.of(context).textTheme.titleMedium),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(size.height * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("오늘의 수면 경험치",
              style: Theme.of(context).textTheme.titleMedium
            ),
            SizedBox(
              height: size.height * 0.02
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return Daily(
                        chosen: DateTime.now(),
                      );
                    }));
              },
              child: Container(
                width: size.width * 0.85,
                height: size.height * 0.15,
                child: Row(
                  children: [
                    SizedBox(
                      width:35
                    ),
                    Text('${experinecePoints}', style:
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
              style: Theme.of(context).textTheme.titleMedium
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Container(
              width: size.width * 0.85,
              height: size.height * 0.35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color(0xffA3BFD9).withOpacity(0.2),
              ),
              padding: EdgeInsets.fromLTRB(size.width * 0.06, size.height * 0.03, size.width * 0.06, size.height * 0.03),
              child: ListView.builder(
                itemCount: dateList.length,
                itemBuilder: (context, index) {
                  DateTime date = dateList[index];
                  String formattedDate = DateFormat('yyyy/MM/dd').format(date); // 날짜 형식 설정

                  return ListTile(
                    title: Text('${formattedDate}: ${experinecePoints} 경험치',
                        style: Theme.of(context).textTheme.bodyMedium),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return Daily(
                              chosen: date,
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