import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ntp/ntp.dart';

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

  Future<void> saveSleepInfo({
    required String date,
    String? sleepStartTime,
    String? wakeUpTime,
    int? remSleep,
    int? lightSleep,
    int? deepSleep,
    int? totalSleepDuration,
    int? sleepScore,
    int? experience,
    int? targetHours,
    String? targetSleepTime,
    String? scheduleScore,
    String? durationScore,
    String? qualityScore,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    final sleepRef = _db
        .collection('Users')
        .doc(user.uid)
        .collection('SleepInfo')
        .doc(date);

    // 필드가 null이 아닌 경우에만 Firestore에 포함
    final sleepData = <String, dynamic>{
      if (sleepStartTime != null) 'sleepStartTime': sleepStartTime,
      if (wakeUpTime != null) 'wakeUpTime': wakeUpTime,
      if (remSleep != null) 'remSleep': remSleep,
      if (lightSleep != null) 'lightSleep': lightSleep,
      if (deepSleep != null) 'deepSleep': deepSleep,
      if (totalSleepDuration != null) 'totalSleepDuration': totalSleepDuration,
      if (sleepScore != null) 'sleepScore': sleepScore,
      if (experience != null) 'experience': experience,
      if (targetHours != null || targetSleepTime != null)
        'sleepGoal': {
          if (targetHours != null) 'targetHours': targetHours,
          if (targetSleepTime != null) 'targetSleepTime': targetSleepTime,
        },
      if (scheduleScore != null || durationScore != null || qualityScore != null)
        'qualities': {
          if (scheduleScore != null) 'scheduleScore': scheduleScore,
          if (durationScore != null) 'durationScore': durationScore,
          if (qualityScore != null) 'qualityScore': qualityScore,
        },
    };

    try {
      await sleepRef.set(sleepData, SetOptions(merge:true)); // 기존 필드를 업데이트
      print('Sleep info updated successfully');
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
      final sleepDoc = await _db
          .collection('Users')
          .doc(user.uid)
          .collection('SleepInfo')
          .doc(date)
          .get();
      if (sleepDoc.exists) {
        return sleepDoc.data();
      }
    } catch (e) {
      print('Error fetching sleep info: $e');
    }
    return null;
  }

  Future<void> saveGoal({
    required String date,
    int? targetHours,
    String? targetSleepTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    final goalRef = _db
        .collection('Users')
        .doc(user.uid)
        .collection('Goal')
        .doc(date);

    final goalData = <String, dynamic>{
      if (targetHours != null) 'targetHours': targetHours,
      if (targetSleepTime != null) 'targetSleepTime': targetSleepTime,
    };

    try {
      await goalRef.set(goalData);
      print('Sleep info updated successfully');
    } catch (e) {
      print('Error saving sleep info: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchGoal({required String date}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return null;
    }

    try {
      final goalDoc = await _db
          .collection('Users')
          .doc(user.uid)
          .collection('Goal')
          .doc(date)
          .get();
      if (goalDoc.exists) {
        return goalDoc.data();
      }
    } catch (e) {
      print('Error fetching sleep info: $e');
    }
    return null;
  }

  // 식물 정보 저장
  Future<void> savePlantInfo({
    DateTime? endDate,
    int? growthStage,
    String? imageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final plantRef = _db
          .collection('Users')
          .doc(user.uid)
          .collection('Plants')
          .doc('currentPlant');

      // 저장할 데이터를 동적으로 구성
      final data = <String, dynamic>{};
      if (endDate != null) data['endDate'] = Timestamp.fromDate(endDate);
      if (growthStage != null) data['growthStage'] = growthStage;
      if (imageUrl != null) data['imageUrl'] = imageUrl;

      await plantRef.set(data, SetOptions(merge: true));

      print('Plant info saved successfully');
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
      final plantDoc = await _db
          .collection('Users')
          .doc(user.uid)
          .collection('Plants')
          .doc('currentPlant')
          .get();
      if (plantDoc.exists) {
        return plantDoc.data();
      }
    } catch (e) {
      print('Error fetching current plant info: $e');
    }
    return null;
  }

  // 식물 백과사전 저장
  Future<void> updatePlantEncyclopedia({
    required String plantId,
    DateTime? endDate,
    String? imageUrl,
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
          .collection('plantsList')
          .doc(plantId);

      final data = <String, dynamic>{};
      if (endDate != null) data['endDate'] = Timestamp.fromDate(endDate);
      if (imageUrl != null) data['imageUrl'] = imageUrl;

      await encyclopediaRef.update(data); // update로 변경
      print('Plant encyclopedia updated successfully');
    } catch (e) {
      print('Error updating plant encyclopedia: $e');
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
          .collection('plantsList')
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching plant encyclopedia: $e');
      return [];
    }
  }

  Future<void> updateMockEncyclopedia() async {
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
          .collection('plantsList');

      await encyclopediaRef.doc('other1').update({
        'startDate': Timestamp.fromDate(DateTime(2024, 11, 3)),
        'endDate': Timestamp.fromDate(DateTime(2024, 12, 4)),
        'nickname': '첫째',
      });
      await encyclopediaRef.doc('other3').update({
        'startDate': Timestamp.fromDate(DateTime(2024, 10, 1)),
        'endDate': Timestamp.fromDate(DateTime(2024, 11, 3)),
        'nickname': '둘째',
      });
      print('Mock data inserted');
    } catch (e) {
      print('Mock 데이터 삽입 실패');
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
