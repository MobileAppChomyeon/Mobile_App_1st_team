import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'pie_chart.dart';


class Daily extends StatelessWidget {

  final DateTime chosen;
  final String sleepStartTime = '11:30 PM';
  final String wakeupTime = '8:31 AM';
  final int remSleep = 80;
  final int lightSleep = 143;
  final int deepSleep = 59;
  int totalSleepDuration = 0;
  final int sleepScore = 100;  // 아직 사용 못함
  final int experiencePoints = 60;

  Daily({
    super.key,
    required this.chosen,
  });

  Map<String, int> minToHour(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return {
      'hours': hours,
      'minutes': minutes,
    };
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

    DateTime start = parseTime(startTime.replaceAll(RegExp(r'[APap][Mm]'), '').trim(), isStartPM);
    DateTime end = parseTime(endTime.replaceAll(RegExp(r'[APap][Mm]'), '').trim(), isEndPM);

    if (end.isBefore(start)) end = end.add(Duration(days: 1));

    Duration difference = end.difference(start);
    return difference.inMinutes;
  }


  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    String message = '어느 정도 주무셨군요!\n 오늘은 조금 더 일찍 잠 들어 보세요';
    totalSleepDuration = calculateDuration(sleepStartTime, wakeupTime);

    return Scaffold(
      backgroundColor: Color(0xffEDF2F7),
      appBar: AppBar(
        backgroundColor: Color(0xffEDF2F7),
        title: Text("잠 기록", style: Theme.of(context).textTheme.titleMedium),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(size.width * 0.08, size.height * 0.04, size.width * 0.08, size.height * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${chosen.month}월 ${chosen.day}일의 수면 기록",
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: size.height * 0.03),
            Row(
              children: [
                Container(
                  width: size.width * 0.41,
                  height: size.height * 0.36,
                  padding: EdgeInsets.all(size.height * 0.03),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "수면 경험치",
                          style: Theme.of(context).textTheme.bodyLarge
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Container(
                        child: CustomPaint( // CustomPaint를 그리고 이 안에 차트를 그려줍니다..
                          size: Size(size.width * 0.25, size.width * 0.25,), // CustomPaint의 크기는 가로 세로 150, 150으로 합니다.
                          painter: PieChart(
                            percentage: experiencePoints, // 파이 차트가 얼마나 칠해져 있는지 정하는 변수입니다.
                            textScaleFactor: 0.8, ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "잠든 시간",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.right,
                                ),
                                Text(
                                  "총 수면 시간",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.right,
                                ),
                                Text(
                                  "수면의 질",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.right,
                                ),
                              ]),
                          SizedBox(width:5),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("좋음",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,),
                                  textAlign: TextAlign.right,
                                ),
                                Text(
                                  "보통",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,),
                                  textAlign: TextAlign.right,
                                ),
                                Text(
                                  "나쁨",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,),
                                  textAlign: TextAlign.right,
                                ),
                              ]),
                        ]
                      )
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
                  height: size.height * 0.36,
                  padding: EdgeInsets.all(size.height * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("수면 시간", style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding: EdgeInsets.only(left: size.width * 0.01),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("잠든 시간", style: Theme.of(context).textTheme.bodyMedium,),
                            Text(sleepStartTime,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 24)),
                            SizedBox(height: size.height * 0.01),
                            Text("깬 시간", style: Theme.of(context).textTheme.bodyMedium,),
                            Text(wakeupTime,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 24)),
                            SizedBox(height: size.height * 0.01),
                            Text("총 수면 시간", style: Theme.of(context).textTheme.bodyMedium,),
                            Text("${minToHour(totalSleepDuration)['hours']}H ${minToHour(totalSleepDuration)['minutes']}M",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 24)),
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
            SizedBox(height: size.height * 0.02),
            Container(
              width: size.width * 0.84,
              height: size.height * 0.2,
              padding: EdgeInsets.fromLTRB(size.width * 0.06, size.height * 0.03, size.width * 0.06, size.height * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("수면의 질", style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(
                    height: size.height * 0.02
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("렘수면", style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 16),),
                            SizedBox(height: size.height * 0.01),
                            Text(
                              "${minToHour(remSleep)['hours']}H ${minToHour(remSleep)['minutes']}M",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 24),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("얕은 수면", style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 16),),
                            SizedBox(height: size.height * 0.01),
                            Text(
                              "${minToHour(lightSleep)['hours']}H ${minToHour(lightSleep)['minutes']}M",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 24),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("깊은 수면", style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 16),),
                            SizedBox(height: size.height * 0.01),
                            Text(
                              "${minToHour(deepSleep)['hours']}H ${minToHour(deepSleep)['minutes']}M",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 24),
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
              height: size.height * 0.03,
            ),
            Text("이날의 메시지", style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.left,),
            SizedBox(
              height: size.height * 0.03
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.04,
                    height: size.height * 0.02,
                    child: SvgPicture.asset('assets/images/quote.svg')
                  ),
                  Text('${message}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,),
                  Container(
                      width: size.width * 0.04,
                      height: size.height * 0.02,
                      child: Transform.rotate(
                          angle: 3.14159, // 라디안 단위로 180도 (PI)
                          child: SvgPicture.asset('assets/images/quote.svg')
                  ),),
                ]
            )

          ],
        ),
      ),
    );
  }
}


