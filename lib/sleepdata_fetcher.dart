import 'package:health/health.dart';
import 'dart:math';
// part of 'health';


  // 수면 데이터 모델 클래스 추가
  class SleepData {
    final DateTime? bedTime;      // 잠든 시간
    final DateTime? wakeTime;     // 일어난 시간
    final Duration lightSleep;    // 얕은 수면
    final Duration deepSleep;     // 깊은 수면
    final Duration remSleep;      // 렘수면

    SleepData({
      this.bedTime,
      this.wakeTime,
      this.lightSleep = Duration.zero,
      this.deepSleep = Duration.zero,
      this.remSleep = Duration.zero,
    });
  }

class SleepDataFetcher {
  static final SleepDataFetcher _instance = SleepDataFetcher._internal();
  final Health _health = Health();

  // 수면 데이터 유형 정의, 잠든시간, 깬시간, 깊은수면, 얕은수면, 렘수면
  static const List<HealthDataType> _sleepDataTypes = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
  ];

  // 싱글톤 팩토리 생성자
  factory SleepDataFetcher() {
    return _instance;
  }

  // private 생성자
  SleepDataFetcher._internal();


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
        startTime: startDate,
        endTime: endDate,
        types: _sleepDataTypes,
      );

      print("수면 데이터 가져오기 성공: ${healthData.length}개의 데이터");
      if (healthData.isEmpty) {
        print("수면 데이터가 없어서 테스트 데이터를 생성합니다.");
        final daysToBring = endDate.difference(startDate).inDays.abs() + 1;
        return _createMockSleepData(endDate, daysToBring);
      }
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

  // 하루치 수면 데이터를 가공하여 반환하는 메소드 추가
  Future<SleepData> getDailySleepData(DateTime date) async {
    final startDate = date.subtract(const Duration(days: 1));
    final endDate = date;

    final data = await fetchSleepData(startDate, endDate);

    DateTime? bedTime;
    DateTime? wakeTime;
    Duration lightSleep = Duration.zero;
    Duration deepSleep = Duration.zero;
    Duration remSleep = Duration.zero;

    for (var point in data) {
      switch (point.type) {
        case HealthDataType.SLEEP_ASLEEP:
          bedTime = point.dateFrom;
          wakeTime = point.dateTo;
          break;
        case HealthDataType.SLEEP_LIGHT:
          lightSleep += point.dateTo.difference(point.dateFrom);
          break;
        case HealthDataType.SLEEP_DEEP:
          deepSleep += point.dateTo.difference(point.dateFrom);
          break;
        case HealthDataType.SLEEP_REM:
          remSleep += point.dateTo.difference(point.dateFrom);
          break;
        default:
          break;
      }
    }

    return SleepData(
      bedTime: bedTime,
      wakeTime: wakeTime,
      lightSleep: lightSleep,
      deepSleep: deepSleep,
      remSleep: remSleep,
    );
  }

  /// 테스트용 수면 데이터 생성
  List<HealthDataPoint> _createMockSleepData(DateTime startDate, int days) {
    final List<HealthDataPoint> mockData = [];
    final Random random = Random();

    for (int i = 0; i < days; i++) {
      final currentDate =
      startDate.subtract(Duration(days: i, minutes: random.nextInt(240)));

      // 총 수면 시간 (240~720분 -> 4시간 ~ 12시간)
      final totalSleepMinutes = 240 + random.nextInt(481); // 최소 240분, 최대 720분
      final sleepStart =
      currentDate.subtract(Duration(minutes: totalSleepMinutes));
      final sleepEnd = currentDate;

      // 각 수면 단계의 시간 생성
      int remSleepMinutes =
      (30 + random.nextDouble() * 90).toInt(); // 30 ~ 120분
      int lightSleepMinutes =
      (60 + random.nextDouble() * 60).toInt(); // 60 ~ 120분
      int deepSleepMinutes =
      (30 + random.nextDouble() * 90).toInt(); // 30 ~ 120분

      // 수면 단계 합이 총 수면 시간 초과 시 조정
      int totalStageMinutes =
          remSleepMinutes + lightSleepMinutes + deepSleepMinutes;
      if (totalStageMinutes > totalSleepMinutes) {
        final adjustmentFactor = totalSleepMinutes / totalStageMinutes;
        remSleepMinutes = (remSleepMinutes * adjustmentFactor).toInt();
        lightSleepMinutes = (lightSleepMinutes * adjustmentFactor).toInt();
        deepSleepMinutes = (deepSleepMinutes * adjustmentFactor).toInt();
      }

      // REM 수면 시작 및 종료 시간
      final remSleepStart = sleepStart.add(Duration(
          minutes: random.nextInt(totalSleepMinutes - totalStageMinutes)));
      final remSleepEnd = remSleepStart.add(Duration(minutes: remSleepMinutes));

      // 얕은 수면 시작 및 종료 시간
      final lightSleepStart = remSleepEnd;
      final lightSleepEnd =
      lightSleepStart.add(Duration(minutes: lightSleepMinutes));

      // 깊은 수면 시작 및 종료 시간
      final deepSleepStart = lightSleepEnd;
      final deepSleepEnd =
      deepSleepStart.add(Duration(minutes: deepSleepMinutes));

      // 총 수면 데이터 생성
      mockData.add(HealthDataPoint(
        type: HealthDataType.SLEEP_ASLEEP,
        uuid: "mock-sleep-$i",
        value: NumericHealthValue(numericValue: totalSleepMinutes.toDouble()),
        dateFrom: sleepStart,
        dateTo: sleepEnd,
        sourceId: "mock-source",
        sourceDeviceId: "mock-device",
        sourceName: "test_source",
        unit: HealthDataUnit.MINUTE,
        sourcePlatform: HealthPlatformType.googleHealthConnect,
      ));

      // REM 수면 데이터
      mockData.add(HealthDataPoint(
        type: HealthDataType.SLEEP_REM,
        uuid: "mock-rem-$i",
        value: NumericHealthValue(numericValue: remSleepMinutes.toDouble()),
        dateFrom: remSleepStart,
        dateTo: remSleepEnd,
        sourceId: "mock-source",
        sourceDeviceId: "mock-device",
        sourceName: "test_source",
        unit: HealthDataUnit.MINUTE,
        sourcePlatform: HealthPlatformType.googleHealthConnect,
      ));

      // 얕은 수면 데이터
      mockData.add(HealthDataPoint(
        type: HealthDataType.SLEEP_LIGHT,
        uuid: "mock-light-$i",
        value: NumericHealthValue(numericValue: lightSleepMinutes.toDouble()),
        dateFrom: lightSleepStart,
        dateTo: lightSleepEnd,
        sourceId: "mock-source",
        sourceDeviceId: "mock-device",
        sourceName: "test_source",
        unit: HealthDataUnit.MINUTE,
        sourcePlatform: HealthPlatformType.googleHealthConnect,
      ));

      // 깊은 수면 데이터
      mockData.add(HealthDataPoint(
        type: HealthDataType.SLEEP_DEEP,
        uuid: "mock-deep-$i",
        value: NumericHealthValue(numericValue: deepSleepMinutes.toDouble()),
        dateFrom: deepSleepStart,
        dateTo: deepSleepEnd,
        sourceId: "mock-source",
        sourceDeviceId: "mock-device",
        sourceName: "test_source",
        unit: HealthDataUnit.MINUTE,
        sourcePlatform: HealthPlatformType.googleHealthConnect,
      ));
    }

    return mockData;
  }
}
