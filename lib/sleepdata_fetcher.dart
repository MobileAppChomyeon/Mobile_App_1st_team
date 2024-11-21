import 'package:health/health.dart';

class SleepDataFetcher {
  final Health _health = Health();

  // 수면 데이터 유형 정의, 잠든시간, 깬시간, 깊은수면, 얕은수면, 렘수면
  static const List<HealthDataType> _sleepDataTypes = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
  ];

  /// HealthKit / Google Fit 초기화
  Future<void> configure() async {
    await _health.configure();
  }

  /// HealthKit / Google Fit 권한 요청
  Future<bool> requestPermissions() async {
    try {
      final bool requested =
          await _health.requestAuthorization(_sleepDataTypes);
      if (requested) {
        print("권한 요청 성공: 수면 데이터에 접근 가능.");
      } else {
        print("권한 요청 실패: 사용자가 권한을 거부했습니다.");
      }
      return requested;
    } catch (e) {
      print("권한 요청 중 오류 발생: $e");
      return false;
    }
  }

  /// 특정 기간 동안의 수면 데이터 가져오기
  Future<List<HealthDataPoint>> fetchSleepData(
      DateTime startDate, DateTime endDate) async {
    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: startDate, // 시작 날
        endTime: endDate, // 종료 날
        types: _sleepDataTypes,
      );

      print("수면 데이터 가져오기 성공: ${healthData.length}개의 데이터");
      return healthData;
    } catch (e) {
      print("수면 데이터 가져오는 중 오류 발생: $e");
      return [];
    }
  }

  /// 수면 데이터 디버깅 및 출력
  Future<void> printSleepData(DateTime startDate, DateTime endDate) async {
    final data = await fetchSleepData(startDate, endDate);

    for (var point in data) {
      print("""
      타입: ${point.type.name}
      값: ${point.value}
      시작: ${point.dateFrom}
      끝: ${point.dateTo}
      """);
    }
  }
}
