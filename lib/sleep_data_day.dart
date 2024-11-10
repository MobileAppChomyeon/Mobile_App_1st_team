import 'package:flutter/material.dart';

class Daily extends StatelessWidget {
  const Daily({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("잠 기록",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height:20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    height: 260,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("수면 경험치", style:
                          TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 40),
                        Text("+ 60", style:
                        TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        SizedBox(height: 20),
                        Text("잠든 시간 good"),
                        Text("수면 시간 good"),
                        Text("수면의 질 good")
                      ],
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFd9d9d9),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    height: 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("잠시간", style:
                        TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height:20),
                        Padding(
                          padding: EdgeInsets.fromLTRB(5,0,0,0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("잠든 시간"),
                              Text("11:30 PM", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)
                              ),
                              Text("깬 시간"),
                              Text("8:31 AM", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)
                              ),
                              Text("총 수면 시간"),
                              Text("9H 1M", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFd9d9d9),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.fromLTRB(10,40,10,40),
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text("렘수면"),
                      SizedBox(height: 10),
                      Text("1H 20M", style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text("얕은 수면"),
                      SizedBox(height: 10),
                      Text("2H 23M", style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text("깊은 수면"),
                      SizedBox(height: 10),
                      Text("59M", style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                      ),
                    ],
                  ),
                ],
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFd9d9d9),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
