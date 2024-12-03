import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 사용자 기본 정보 저장
  Future<void> saveUserInfo({
    required String backgroundImage,
    required String description,
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
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user info: $e');
    }
  }

  // **사용자 기본 정보 가져오기**
  Future<Map<String, dynamic>?> fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return null;
    }

    try {
      final userDoc = await _db.collection('Users').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
    return null;
  }

  // 수면 정보 저장
  Future<void> saveSleepInfo({
    required String sleepStartTime,
    required String wakeUpTime,
    required int remSleep,
    required int lightSleep,
    required int deepSleep,
    required int totalSleepDuration,
    required int sleepScore,
    required int experience,
    required int targetHours,
    required String targetSleepTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    final today = DateTime.now().toIso8601String().split('T')[0];
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
        'experience': experience,
        'sleepGoal': {
          'targetHours': targetHours,
          'targetSleepTime': targetSleepTime,
        },
      });
    } catch (e) {
      print('Error saving sleep info: $e');
    }
  }

  // **수면 정보 가져오기**
  Future<Map<String, dynamic>?> fetchSleepInfo({required String date}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return null;
    }

    try {
      final sleepDoc = await _db.collection('Users').doc(user.uid).collection('SleepInfo').doc(date).get();
      if (sleepDoc.exists) {
        return sleepDoc.data();
      }
    } catch (e) {
      print('Error fetching sleep info: $e');
    }
    return null;
  }

  // 식물 정보 저장
  Future<void> savePlantInfo({
    required String? nickname,
    required DateTime startDate,
    required DateTime? endDate,
    required String status,
    required String growthStage,
    required String imageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final plantRef = _db.collection('Users').doc(user.uid).collection('Plants').doc('currentPlant');
      await plantRef.set({
        'nickname': nickname,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
        'status': status,
        'growthStage': growthStage,
        'imageUrl': imageUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving plant info: $e');
    }
  }

  // **현재 식물 정보 가져오기**
  Future<Map<String, dynamic>?> fetchCurrentPlantInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return null;
    }

    try {
      final plantDoc = await _db.collection('Users').doc(user.uid).collection('Plants').doc('currentPlant').get();
      if (plantDoc.exists) {
        return plantDoc.data();
      }
    } catch (e) {
      print('Error fetching current plant info: $e');
    }
    return null;
  }

  // 식물 백과사전 저장
  Future<void> savePlantEncyclopedia({
    required String? nickname,
    required String plantId,
    required DateTime startDate,
    required DateTime endDate,
    required String description,
    required String growthStatus,
    required List<String> growthStages,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final encyclopediaRef = _db
          .collection('Users')
          .doc(user.uid)
          .collection('Plants')
          .doc('encyclopedia')
          .collection('entries')
          .doc(plantId);

      await encyclopediaRef.set({
        'nickname': nickname,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'description': description,
        'growthStatus': growthStatus,
        'growthStages': growthStages,
      });
    } catch (e) {
      print('Error saving plant encyclopedia: $e');
    }
  }

  // **식물 백과사전 가져오기**
  Future<List<Map<String, dynamic>>> fetchPlantEncyclopedia() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return [];
    }

    try {
      final querySnapshot = await _db
          .collection('Users')
          .doc(user.uid)
          .collection('Plants')
          .doc('encyclopedia')
          .collection('entries')
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching plant encyclopedia: $e');
      return [];
    }
  }
}
/*
사용 예시
void exampleUsage() async {
  final userService = UserDataService();

  // 유저 기본 정보 가져오기
  final userInfo = await userService.fetchUserInfo();
  print('User Info: $userInfo');

  // 수면 정보 가져오기
  final sleepInfo = await userService.fetchSleepInfo(date: '2024-12-01');
  print('Sleep Info: $sleepInfo');

  // 현재 식물 정보 가져오기
  final currentPlant = await userService.fetchCurrentPlantInfo();
  print('Current Plant: $currentPlant');

  // 식물 백과사전 가져오기
  final encyclopedia = await userService.fetchPlantEncyclopedia();
  print('Plant Encyclopedia: $encyclopedia');
}


 */