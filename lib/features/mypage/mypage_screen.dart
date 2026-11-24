import 'package:flutter/material.dart';
import '../../core/run_raid_store.dart';
import '../auth/auth_provider.dart';

class MyPageScreen extends StatelessWidget {
  final AuthController authController;
  final RunRaidStore store;

  const MyPageScreen({
    super.key,
    required this.authController,
    required this.store,
  });

  void _handleAttendance(BuildContext context) {
    final bonus = store.checkAttendance();
    if (bonus <= 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '출석 체크 완료! 연속 ${store.streakDays}일 · +$bonus PT 적립',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mergedListenable = Listenable.merge([authController, store]);

    return AnimatedBuilder(
      animation: mergedListenable,
      builder: (context, _) {
        final authState = authController.state;
        final nickname = authState.nickname ?? '게스트 러너';
        final role = authState.role;

        final personalKm = store.personalDistanceKm.toStringAsFixed(1);
        final raidKm = store.raidDistanceKm.toStringAsFixed(1);
        final totalKm = store.totalDistanceKm.toStringAsFixed(1);
        final tier = store.tierLabel;
        final missions = store.missions;
        final recentRuns = store.recentRuns;

        return Scaffold(
          appBar: AppBar(
            title: const Text('마이페이지'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(nickname),
                  subtitle: Text(
                    '${authState.nickname != null ? '로그인' : '게스트'} · 권한: $role · 티어: $tier',
                  ),
                  trailing: Chip(label: Text('연속 ${store.streakDays}일')),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '총 누적 거리',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '합계 $totalKm km · ${store.rewardPoints} PT',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('개인 러닝: $personalKm km'),
                          Text('레이드 거리: $raidKm km'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: store.checkedToday
                              ? null
                              : () => _handleAttendance(context),
                          icon: const Icon(Icons.check_circle),
                          label: Text(
                            store.checkedToday ? '오늘 출석 완료' : '일일 출석 체크 (+PT)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '러너 미션',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...missions.map(
                (m) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              m.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              label: Text(
                                m.isCompleted ? '달성!' : '+${m.rewardPoints} PT',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.description,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: m.progress),
                        const SizedBox(height: 6),
                        Text(
                          '${m.currentValue.toStringAsFixed(m.unit == 'km' ? 1 : 0)} / ${m.targetValue.toStringAsFixed(m.unit == 'km' ? 1 : 0)} ${m.unit}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '최근 러닝 기록',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...recentRuns.map(
                (run) => Card(
                  child: ListTile(
                    leading: Icon(
                      run.isRaid ? Icons.shield_moon : Icons.directions_run,
                    ),
                    title: Text(run.title),
                    subtitle: Text(run.detail),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}