import 'package:flutter/material.dart';
import '../../core/run_raid_store.dart';
import '../auth/auth_provider.dart';

class RaidScreen extends StatelessWidget {
  final AuthController authController;
  final RunRaidStore store;

  const RaidScreen({
    super.key,
    required this.authController,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final mergedListenable = Listenable.merge([authController, store]);

    return AnimatedBuilder(
      animation: mergedListenable,
      builder: (context, _) {
        final state = authController.state;
        final nickname = state.nickname ?? '게스트 러너';
        final role = state.role;

        final currentHp = store.bossCurrentHp;
        final maxHp = store.bossMaxHp;
        final ratio = store.bossHpRatio;
        final isDefeated = currentHp <= 0;
        final rankers = store.leaderboard(nickname);

        return Scaffold(
          appBar: AppBar(
            title: const Text('보스 레이드'),
            actions: [
              TextButton(
                onPressed: store.resetBossForTest,
                child: const Text('보스 리셋'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              store.bossName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(isDefeated ? '처치 완료!' : '진행 중'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '보스 HP: $currentHp / $maxHp (${(ratio * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: ratio,
                        minHeight: 12,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        store.lastDamageText,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (isDefeated) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: store.advanceToNextBoss,
                            icon: const Icon(Icons.skip_next),
                            label: const Text('다음 보스 도전하기'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '내 레이드 기여 현황',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '참여자: $nickname (${state.nickname != null ? '로그인됨' : '비로그인'} · $role)',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '누적 레이드 거리: ${store.raidDistanceKm.toStringAsFixed(1)} km',
                      ),
                      const SizedBox(height: 4),
                      Text('누적 입힌 데미지: ${store.myRaidDamage} DMG'),
                      const SizedBox(height: 4),
                      Text('레이드 참여 횟수: ${store.raidParticipationCount}회'),
                      const SizedBox(height: 4),
                      Text(
                        '보스 처치: ${store.defeatedBossCount}회 · 누적 보상: ${store.rewardPoints} PT',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '레이드 기여 랭킹',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...rankers.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final r = entry.value;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('$rank')),
                    title: Text(r.isMe ? '${r.name} (나)' : r.name),
                    subtitle: Text(
                      '${r.tier} · 누적 ${r.distanceKm.toStringAsFixed(1)} km',
                    ),
                    trailing: Text(
                      '${r.damage} DMG',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('참여 방법'),
                  subtitle: Text(
                    '하단 [러닝] 탭에서 [레이드 참여] 모드를 선택한 뒤 달리고 [종료]를 누르면 거리가 데미지로 반영됩니다.',
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