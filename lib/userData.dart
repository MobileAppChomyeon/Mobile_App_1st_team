import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 사용자 기본 정보 저장
  Future<void> saveUserInfo({
    required String backgroundImage, //배경정보
    required String description, // 배경 설명
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final userRef = _db.collection('Users').doc(user.uid);
      await userRef.set({
        'backgroundImage': backgroundImage,
        'description': description,
      }, SetOptions(merge: true)); // 기존 데이터를 덮어쓰지 않고 추가
    } catch (e) {
      print('Error saving user info: $e');
    }
  }

  // 수면 정보 저장
  Future<void> saveSleepInfo({
    required String sleepStartTime, //잠에 든 시각
    required String wakeUpTime, //일어난 시각
    required int remSleep, //렘수면
    required int lightSleep, //얕은수면
    required int deepSleep, //깊은 수면
    required int totalSleepDuration, // 총 수면 시간
    required int sleepScore, // 수면점수
    required int targetHours, // 목표 수면 시간 (얼마나 잘지)
    required String targetSleepTime, // 목표 수면 시각 (몇시 몇분)
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD 형식으로 날짜 생성
    final sleepRef = _db.collection('Users').doc(user.uid).collection('SleepInfo').doc(today);

    try {
      await sleepRef.set({
        'sleepStartTime': sleepStartTime,
        'wakeUpTime': wakeUpTime,
        'remSleep': remSleep,
        'lightSleep': lightSleep,
        'deepSleep': deepSleep,
        'totalSleepDuration': totalSleepDuration,
        'sleepScore': sleepScore,
        'sleepGoal': {
          'targetHours': targetHours,
          'targetSleepTime': targetSleepTime,
        },
      });
    } catch (e) {
      print('Error saving sleep info: $e');
    }
  }

  // 식물 정보 저장
  Future<void> savePlantInfo({
    required String? nickname,
    required DateTime startDate,
    required DateTime? endDate, // endDate는 null일 수 있음
    required String status, // "growing" or "complete"
    required String growthStage, // "sprout", "grow", "flowers", "complete"
    required String imageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final plantRef = _db.collection('Users').doc(user.uid).collection('Plants').doc('currentPlant');

      // endDate가 null일 경우에는 null로 저장, 그렇지 않으면 Timestamp로 변환하여 저장
      await plantRef.set({
        'nickname': nickname,
        'startDate': Timestamp.fromDate(startDate), // DateTime -> Timestamp
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null, // endDate가 null이면 null 저장
        'status': status,
        'growthStage': growthStage,
        'imageUrl': imageUrl,
      }, SetOptions(merge: true)); // merge: true 옵션을 추가하여 기존 데이터를 덮어쓰지 않도록
    } catch (e) {
      print('Error saving plant info: $e');
    }
  }

  // 식물 백과사전 저장
  Future<void> savePlantEncyclopedia({
    required String? nickname,
    required String plantId,
    required DateTime startDate,
    required DateTime endDate,
    required String description,
    required String growthStatus, // incomplete, complete
    required List<String> growthStages, // List of growth stages (["sprout", "grow", "flowers", "complete"])
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      // "Users/{user.uid}/Plants/encyclopedia/{plantId}" 경로로 서브컬렉션에 접근
      final encyclopediaRef = _db
          .collection('Users')
          .doc(user.uid)
          .collection('Plants') // "Plants" 컬렉션
          .doc('encyclopedia')  // 'encyclopedia'를 문서로 처리
          .collection('entries') // entries 서브컬렉션 추가
          .doc(plantId); // plantId에 해당하는 문서를 지정

      await encyclopediaRef.set({
        'nickname': nickname,
        'startDate': Timestamp.fromDate(startDate), // DateTime -> Timestamp
        'endDate': Timestamp.fromDate(endDate), // DateTime -> Timestamp
        'description': description,
        'growthStatus': growthStatus,
        'growthStages': growthStages,
      });
    } catch (e) {
      print('Error saving plant encyclopedia: $e');
    }
  }
}
