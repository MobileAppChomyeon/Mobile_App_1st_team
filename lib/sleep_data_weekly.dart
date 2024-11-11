import 'package:flutter/material.dart';
import 'sleep_data_day.dart';

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
        fontFamily: 'Pretendard'
      ),
      home: const MyHomePage(title: '잠 기록'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(widget.title,
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("오늘의 잠 경험치",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("60", style:
                  TextStyle(fontWeight: FontWeight.bold,fontSize: 60),
                    textAlign: TextAlign.left,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("수면시간: 30점"),
                      Text("수면의 질: 20점"),
                      Text("그밖의 점수: 10점")
                    ],
                  ),
                ],
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFd9d9d9),
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
            ),
            SizedBox(
              height: 60,
            ),
            Text("지난날의 잠 경험치",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height:10,
            ),
            Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: Text("2024/11/03: 30 경험치"),
                      onTap: () {
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return Daily();
                              }));
                        },
                      trailing: Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      title: Text("2024/11/02: 30 경험치"),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return Daily();
                            }));
                      },
                        trailing: Icon(Icons.chevron_right)
                    ),
                    ListTile(
                      title: Text("2024/11/01: 30 경험치"),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return Daily();
                            }));
                      },
                        trailing: Icon(Icons.chevron_right)
                    ),
                    ListTile(
                      title: Text("2024/10/31: 40 경험치"),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return Daily();
                            }));
                      },
                        trailing: Icon(Icons.chevron_right)
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}