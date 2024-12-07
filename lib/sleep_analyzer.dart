import 'sleepdata_fetcher.dart';  // SleepData 클래스를 위한 import

class SleepAnalyzer {
  final DateTime preferredBedTime;    // 목표 취침 시간
  final DateTime preferredWakeTime;   // 목표 기상 시간
  final Duration preferredSleepTime;  // 목표 수면 시간

  SleepAnalyzer({
    required this.preferredBedTime,
    required this.preferredWakeTime,
    required this.preferredSleepTime,
  });

  // 총 수면 점수 계산 (0-100점)
  int calculateSleepScore(SleepData sleepData) {
    if (sleepData.bedTime == null || sleepData.wakeTime == null) {
      return 0;  // 수면 데이터가 없는 경우
    }

    int score = 100;
    
    score += _calculateBedTimeScore(sleepData.bedTime!);
    score += _calculateWakeTimeScore(sleepData.wakeTime!);
    score += _calculateTotalSleepScore(sleepData);
    score += _calculateDeepSleepBonus(sleepData);
    score += _calculateRemSleepBonus(sleepData);

    return score.clamp(0, 100);
  }

  // 수면 품질 종합 평가 (시간대, 시간, 질 순서로 반환)
  List<String> evaluateSleepQuality(SleepData sleepData) {
    List<String> qualities = [];
    
    // 1. 수면 시간대 평가
    int scheduleScore = _calculateBedTimeScore(sleepData.bedTime!) + 
                       _calculateWakeTimeScore(sleepData.wakeTime!);
    qualities.add(scheduleScore >= 30 ? '좋음' : scheduleScore >= 15 ? '보통' : '나쁨');
    
    // 2. 총 수면 시간 평가
    int durationScore = _calculateTotalSleepScore(sleepData);
    qualities.add(durationScore >= 15 ? '좋음' : durationScore >= 8 ? '보통' : '나쁨');
    
    // 3. 수면의 질 평가
    int qualityScore = _calculateDeepSleepBonus(sleepData) + 
                      _calculateRemSleepBonus(sleepData);
    qualities.add(qualityScore >= 15 ? '좋음' : qualityScore >= 8 ? '보통' : '나쁨');
    
    return qualities;  // [시간대 평가, 시간 평가, 질 평가] 순서로 반환
  }

  // 잠든 시간 점수 계산
  int _calculateBedTimeScore(DateTime bedTime) {
    // 목표 취침 시간과의 차이를 분 단위로 계산
    final difference = bedTime.difference(preferredBedTime).inMinutes;
    
    // 목표 시간보다 일찍 자는 경우는 만점
    if (difference <= 0) return 20;
    
    // 30분당 10점 감점
    final score = 20 - (difference / 30 * 10).round();
    return score.clamp(0, 20);
  }

  // 기상 시간 점수 계산
  int _calculateWakeTimeScore(DateTime wakeTime) {
    // 목표 기상 시간과의 차이를 분 단위로 계산
    final difference = wakeTime.difference(preferredWakeTime).inMinutes;
    
    // 목표 시간보다 일찍 일어나는 경우는 만점
    if (difference <= 0) return 20;
    
    // 30분당 10점 감점
    final score = 20 - (difference / 30 * 10).round();
    return score.clamp(0, 20);
  }

  // 총 수면 시간 점수 계산
  int _calculateTotalSleepScore(SleepData sleepData) {
    if (sleepData.bedTime == null || sleepData.wakeTime == null) {
      return 0;
    }

    // 실제 수면 시간 계산
    final actualSleepDuration = sleepData.wakeTime!.difference(sleepData.bedTime!);
    
    // 목표 수면 시간과의 차이를 시간 단위로 계산 (절대값)
    final differenceInHours = (actualSleepDuration.inMinutes - preferredSleepTime.inMinutes).abs() / 60;
    
    // 기본 20점에서 1시간당 10점씩 감점
    final score = 20 - (differenceInHours * 10).round();
    
    return score.clamp(0, 20);
  }

  // 깊은 수면 보너스 점수 계산
  int _calculateDeepSleepBonus(SleepData sleepData) {
    if (sleepData.bedTime == null || sleepData.wakeTime == null) {
      return 0;
    }

    // 총 수면 시간 계산
    final totalSleepMinutes = sleepData.wakeTime!.difference(sleepData.bedTime!).inMinutes;
    
    // 깊은 수면 비율 계산 (퍼센트)
    final deepSleepPercentage = (sleepData.deepSleep.inMinutes / totalSleepMinutes) * 100;
    
    // 10~20% 사이면 보너스 10점
    return (deepSleepPercentage >= 10 && deepSleepPercentage <= 20) ? 10 : 0;
  }

  // REM 수면 보너스 점수 계산
  int _calculateRemSleepBonus(SleepData sleepData) {
    if (sleepData.bedTime == null || sleepData.wakeTime == null) {
      return 0;
    }

    // 총 수면 시간 계산
    final totalSleepMinutes = sleepData.wakeTime!.difference(sleepData.bedTime!).inMinutes;
    
    // REM 수면 비율 계산 (퍼센트)
    final remSleepPercentage = (sleepData.remSleep.inMinutes / totalSleepMinutes) * 100;
    
    // 15~30% 사이면 보너스 10점
    return (remSleepPercentage >= 15 && remSleepPercentage <= 30) ? 10 : 0;
  }

  // 수면 점수에 따른 피드백 메시지
  String getSleepFeedback(int score) {
    if (score >= 90) {
      return "완벽한 수면이에요!\n최고의 컨디션이겠어요. 😊";
    } else if (score >= 80) {
      return "잘 주무셨네요!\n상쾌한 하루 되세요. ✨";
    } else if (score >= 70) {
      return "괜찮은 수면이었어요.\n조금 더 신경 쓰면 더 좋아질 거예요. 💪";
    } else if (score >= 60) {
      return "수면 패턴이 불규칙해요.\n일정한 시간에 자고 일어나보세요. 🌙";
    } else if (score >= 50) {
      return "수면의 질이 좋지 않아요.\n취침 전 루틴을 만들어보는 건 어떨까요? 💭";
    } else {
      return "수면 관리가 필요해요.\n규칙적인 수면 습관을 만들어보세요. 😴";
    }
  }
} 