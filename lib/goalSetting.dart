import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalSetting extends StatefulWidget {
  const GoalSetting({super.key});

  @override
  State<GoalSetting> createState() => _GoalSettingState();
}

class _GoalSettingState extends State<GoalSetting> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  int targetHours = 8;
  String targetSleepTime = '오후 11시';

  int setTargetHours = 8; // 기본값으로 8시간
  String setTargetSleepTime = '오후 11시'; // 기본값으로 오후 11시

  void formatTime(TimeOfDay time) {
    String goalTime = time.hour >= 12 ? '오후' : '오전';
    int goalHour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    int goalMinute = time.minute;

    if (goalMinute == 0) {
      setTargetSleepTime = '$goalTime $goalHour시';
    } else {
      setTargetSleepTime = '$goalTime $goalHour시 $goalMinute분';
    }
  }

  List<int> numbers = List.generate(24, (index) => index + 1);

  void _onPickerChanged(int value) {
    setState(() {
      setTargetHours = value + 1;
    });
  }

  void _showNumberPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return CupertinoPicker(
          itemExtent: 40,
          scrollController: FixedExtentScrollController(initialItem: setTargetHours - 1),
          onSelectedItemChanged: _onPickerChanged,
          children: numbers
              .map((number) => Center(
            child: Text(
              number.toString(),
              style: const TextStyle(fontSize: 24),
            ),
          ))
              .toList(),
        );
      },
    );
  }

  // Load the current sleep goal from Firestore
  Future<void> loadSleepGoal() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final sleepGoalRef = await _db
          .collection('Users')
          .doc(user.uid)
          .collection('SleepInfo')
          .doc('today')
          .get();

      if (sleepGoalRef.exists) {
        setState(() {
          targetHours = sleepGoalRef['sleepGoal']['targetHours'];
          targetSleepTime = sleepGoalRef['sleepGoal']['targetSleepTime'];
        });
      } else {
        print('No data found for sleep goal');
      }
    } catch (e) {
      print('Error loading sleep goal: $e');
    }
  }

  // Update the sleep goal in Firestore
  Future<void> updateSleepGoal(int hour, String time) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    final sleepGoalRef = _db
        .collection('Users')
        .doc(user.uid)
        .collection('SleepInfo')
        .doc('today');

    try {
      await sleepGoalRef.set({
        'sleepGoal': {
          'targetHours': hour,
          'targetSleepTime': time,
        },
      }, SetOptions(merge: true));

      // After updating Firestore, reload the updated sleep goal
      loadSleepGoal();
    } catch (e) {
      print('Error updating sleep goal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('수면 설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: loadSleepGoal(),
        builder: (context, snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(size.width * 0.08, size.height * 0.03, size.width * 0.08, size.height * 0.03),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.05),
                      const Text(
                        '현재 수면 목표',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        '$targetHours시간, $targetSleepTime 취침을,',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.06),
                Container(
                  padding: EdgeInsets.fromLTRB(
                      size.width * 0.13, size.height * 0.03, size.width * 0.13, size.height * 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: size.height * 0.01),
                          TextButton(
                            style: TextButton.styleFrom(
                              alignment: Alignment.centerRight,
                            ),
                            onPressed: _showNumberPicker,
                            child: Text(
                              setTargetHours.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          TextButton(
                            style: TextButton.styleFrom(
                              alignment: Alignment.centerRight,
                            ),
                            onPressed: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                initialEntryMode: TimePickerEntryMode.input,
                              );

                              if (pickedTime != null) {
                                setState(() {
                                  formatTime(pickedTime);
                                });
                              }
                            },
                            child: Text(
                              '$setTargetSleepTime',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '시간,',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),
                          Text(
                            '취침',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: const GradientBoxBorder(
                      gradient: LinearGradient(colors: [Color(0xffA3BFD9), Color(0xffC1E1C1)]),
                      width: 3,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.06),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '으로 바꾸겠습니다',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.17),
                ElevatedButton(
                  onPressed: () async {
                    // Update the sleep goal in Firestore
                    await updateSleepGoal(setTargetHours, setTargetSleepTime);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('저장되었습니다!'),
                        duration: const Duration(seconds: 2), // 메시지 표시 시간
                        behavior: SnackBarBehavior.floating, // 화면에 띄우는 형식
                      ),
                    );
                  },
                  child: Text(
                    '목표 저장하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff4A6FA5),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size(size.width * 0.88, size.height * 0.06)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
