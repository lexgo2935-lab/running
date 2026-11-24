import 'package:flutter/foundation.dart';

class RunRecordItem {
  final String title;
  final String detail;
  final double distanceKm;
  final bool isRaid;

  const RunRecordItem({
    required this.title,
    required this.detail,
    required this.distanceKm,
    this.isRaid = false,
  });
}

class BossTemplate {
  final String name;
  final int maxHp;
  final int rewardPoints;

  const BossTemplate({
    required this.name,
    required this.maxHp,
    required this.rewardPoints,
  });
}

class RaidRanker {
  final String name;
  final String tier;
  final int damage;
  final double distanceKm;
  final bool isMe;

  const RaidRanker({
    required this.name,
    required this.tier,
    required this.damage,
    required this.distanceKm,
    this.isMe = false,
  });
}

class RunnerMission {
  final String id;
  final String title;
  final String description;
  final double currentValue;
  final double targetValue;
  final String unit;
  final int rewardPoints;

  const RunnerMission({
    required this.id,
    required this.title,
    required this.description,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.rewardPoints,
  });

  double get progress =>
      targetValue <= 0 ? 0 : (currentValue / targetValue).clamp(0.0, 1.0);

  bool get isCompleted => currentValue >= targetValue;
}

class RunRaidStore extends ChangeNotifier {
  double _personalDistanceKm = 24.8;
  double _raidDistanceKm = 18.2;

  int _streakDays = 4;
  bool _checkedToday = false;

  static const List<BossTemplate> _bossPool = [
    BossTemplate(name: 'IRON PACE TITAN', maxHp: 1000, rewardPoints: 300),
    BossTemplate(name: 'CRIMSON SPRINT WYVERN', maxHp: 1500, rewardPoints: 500),
    BossTemplate(name: 'APEX MARATHON COLOSSUS', maxHp: 2200, rewardPoints: 800),
  ];

  int _bossIndex = 0;
  int _bossCurrentHp = 680;
  int _defeatedBossCount = 0;
  int _rewardPoints = 0;
  int _myRaidDamage = 320;
  int _raidParticipationCount = 1;
  String _lastDamageText = '아직 이번 세션에서 입힌 데미지가 없습니다.';

  final List<RunRecordItem> _recentRuns = [
    const RunRecordItem(
      title: '개인 프리 러닝',
      detail: '5.2 km · 페이스 5\'20"/km · 어제',
      distanceKm: 5.2,
      isRaid: false,
    ),
    const RunRecordItem(
      title: '보스 레이드 참여',
      detail: '4.1 km · 페이스 5\'35"/km · 3일 전',
      distanceKm: 4.1,
      isRaid: true,
    ),
    const RunRecordItem(
      title: '티어 상승 러닝',
      detail: '3.1 km · 페이스 5\'10"/km · 5일 전',
      distanceKm: 3.1,
      isRaid: false,
    ),
  ];

  double get personalDistanceKm => _personalDistanceKm;
  double get raidDistanceKm => _raidDistanceKm;
  double get totalDistanceKm => _personalDistanceKm + _raidDistanceKm;

  int get streakDays => _streakDays;
  bool get checkedToday => _checkedToday;

  BossTemplate get currentBoss => _bossPool[_bossIndex % _bossPool.length];
  String get bossName => currentBoss.name;
  int get bossMaxHp => currentBoss.maxHp;
  int get bossCurrentHp => _bossCurrentHp;
  int get defeatedBossCount => _defeatedBossCount;
  int get rewardPoints => _rewardPoints;
  int get myRaidDamage => _myRaidDamage;
  int get raidParticipationCount => _raidParticipationCount;
  String get lastDamageText => _lastDamageText;
  List<RunRecordItem> get recentRuns => List.unmodifiable(_recentRuns);

  double get bossHpRatio =>
      bossMaxHp <= 0 ? 0 : (_bossCurrentHp / bossMaxHp).clamp(0.0, 1.0);

  String get tierLabel {
    final total = totalDistanceKm;
    if (total >= 120) return 'DIAMOND I';
    if (total >= 80) return 'PLATINUM II';
    if (total >= 55) return 'GOLD I';
    if (total >= 35) return 'GOLD III';
    return 'SILVER II';
  }

  List<RunnerMission> get missions => [
        RunnerMission(
          id: 'total_50km',
          title: '누적 50 km 러너',
          description: '개인 + 레이드 합산 누적 거리 50 km 달성',
          currentValue: totalDistanceKm,
          targetValue: 50.0,
          unit: 'km',
          rewardPoints: 250,
        ),
        RunnerMission(
          id: 'raid_5runs',
          title: '레이드 선봉대',
          description: '보스 레이드 누적 5회 참여',
          currentValue: _raidParticipationCount.toDouble(),
          targetValue: 5.0,
          unit: '회',
          rewardPoints: 400,
        ),
        RunnerMission(
          id: 'streak_7days',
          title: '7일 연속 출석 스트릭',
          description: '연속 출석 7일 달성',
          currentValue: _streakDays.toDouble(),
          targetValue: 7.0,
          unit: '일',
          rewardPoints: 200,
        ),
      ];

  List<RaidRanker> leaderboard(String myNickname) {
    final list = <RaidRanker>[
      const RaidRanker(
        name: '도현스피드',
        tier: 'GOLD III',
        damage: 1180,
        distanceKm: 41.5,
      ),
      const RaidRanker(
        name: '현재페이서',
        tier: 'PLATINUM II',
        damage: 860,
        distanceKm: 84.0,
      ),
      RaidRanker(
        name: myNickname,
        tier: tierLabel,
        damage: _myRaidDamage,
        distanceKm: totalDistanceKm,
        isMe: true,
      ),
      const RaidRanker(
        name: '냉정트랙킹',
        tier: 'SILVER II',
        damage: 540,
        distanceKm: 28.4,
      ),
    ];

    list.sort((a, b) => b.damage.compareTo(a.damage));
    return list;
  }

  int checkAttendance() {
    if (_checkedToday) return 0;
    _checkedToday = true;
    _streakDays += 1;
    final bonusPt = 50 + (_streakDays * 10);
    _rewardPoints += bonusPt;
    notifyListeners();
    return bonusPt;
  }

  void addRunRecord({
    required double distanceKm,
    required String durationText,
    required String paceText,
    bool isRaid = false,
  }) {
    if (distanceKm <= 0) return;

    if (isRaid) {
      _raidDistanceKm += distanceKm;
      final rawDamage = (distanceKm * 100).round().clamp(1, bossMaxHp);
      final appliedDamage =
          rawDamage > _bossCurrentHp ? _bossCurrentHp : rawDamage;

      _bossCurrentHp = (_bossCurrentHp - appliedDamage).clamp(0, bossMaxHp);
      _myRaidDamage += appliedDamage;
      _raidParticipationCount += 1;

      if (_bossCurrentHp == 0) {
        final reward = currentBoss.rewardPoints;
        _defeatedBossCount += 1;
        _rewardPoints += reward;
        _lastDamageText =
            '${distanceKm.toStringAsFixed(2)} km 완주로 $appliedDamage 데미지! [$bossName] 처치 (+$reward PT)';
      } else {
        _lastDamageText =
            '${distanceKm.toStringAsFixed(2)} km 완주로 보스에게 $appliedDamage 데미지!';
      }
    } else {
      _personalDistanceKm += distanceKm;
    }

    _recentRuns.insert(
      0,
      RunRecordItem(
        title: isRaid ? '보스 레이드 참여' : '개인 프리 러닝',
        detail:
            '${distanceKm.toStringAsFixed(2)} km · 페이스 $paceText/km · 시간 $durationText',
        distanceKm: distanceKm,
        isRaid: isRaid,
      ),
    );

    notifyListeners();
  }

  void advanceToNextBoss() {
    _bossIndex = (_bossIndex + 1) % _bossPool.length;
    _bossCurrentHp = currentBoss.maxHp;
    _lastDamageText = '새 보스 [$bossName] 등장! (HP $bossMaxHp)';
    notifyListeners();
  }

  void resetBossForTest() {
    _bossCurrentHp = bossMaxHp;
    _lastDamageText = '[$bossName] HP가 최대치($bossMaxHp)로 초기화되었습니다.';
    notifyListeners();
  }
}