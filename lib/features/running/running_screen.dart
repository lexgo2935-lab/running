import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/run_raid_store.dart';

class RunningScreen extends StatefulWidget {
  final RunRaidStore store;

  const RunningScreen({
    super.key,
    required this.store,
  });

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isMockMode = true;
  bool _isRaidRun = false;

  int _elapsedSeconds = 0;
  double _distanceKm = 0.0;
  Timer? _timer;

  void _startRun() {
    if (_isRunning && !_isPaused) return;
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds += 1;
        if (_isMockMode) {
          _distanceKm += 0.0033;
        }
      });
    });
  }

  void _pauseRun() {
    if (!_isRunning || _isPaused) return;
    _timer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  void _finishRun() {
    _timer?.cancel();
    final finishedKm = _distanceKm;
    final finishedKmText = finishedKm.toStringAsFixed(2);
    final finishedTime = _formatDuration(_elapsedSeconds);
    final finishedPace = _formatPace();

    if (finishedKm > 0.001) {
      widget.store.addRunRecord(
        distanceKm: finishedKm,
        durationText: finishedTime,
        paceText: finishedPace,
        isRaid: _isRaidRun,
      );
    }

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _elapsedSeconds = 0;
      _distanceKm = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('러닝 종료! 거리 $finishedKmText km · 시간 $finishedTime (기록 저장됨)'),
      ),
    );
  }

  void _addMockDistance(double addKm) {
    setState(() {
      _distanceKm += addKm;
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatPace() {
    if (_distanceKm <= 0.01) return '--\'--"';
    final paceMinPerKm = (_elapsedSeconds / 60) / _distanceKm;
    final mins = paceMinPerKm.floor();
    final secs = ((paceMinPerKm - mins) * 60).round().toString().padLeft(2, '0');
    return '$mins\'$secs"';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('러닝 트래커'),
        actions: [
          Row(
            children: [
              const Text('테스트 모드', style: TextStyle(fontSize: 13)),
              Switch(
                value: _isMockMode,
                onChanged: (value) {
                  setState(() {
                    _isMockMode = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: false,
                label: Text('개인 러닝'),
                icon: Icon(Icons.directions_run),
              ),
              ButtonSegment<bool>(
                value: true,
                label: Text('레이드 참여'),
                icon: Icon(Icons.shield_moon),
              ),
            ],
            selected: {_isRaidRun},
            onSelectionChanged: _isRunning
                ? null
                : (selection) {
                    setState(() {
                      _isRaidRun = selection.first;
                    });
                  },
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${_distanceKm.toStringAsFixed(2)} km',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('경과 시간', style: TextStyle(color: Colors.grey)),
                          Text(
                            _formatDuration(_elapsedSeconds),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('평균 페이스', style: TextStyle(color: Colors.grey)),
                          Text(
                            '${_formatPace()}/km',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: (!_isRunning || _isPaused) ? _startRun : null,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(_isPaused ? '재개' : '시작'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_isRunning && !_isPaused) ? _pauseRun : null,
                  icon: const Icon(Icons.pause),
                  label: const Text('일시정지'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _isRunning ? _finishRun : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('종료'),
                ),
              ),
            ],
          ),
          if (_isMockMode) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mock 센서 테스트 패널',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'GPS/센서 없이 거리를 빠르게 올려서 UI와 페이스를 검증합니다.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => _addMockDistance(0.5),
                          child: const Text('+0.5 km'),
                        ),
                        OutlinedButton(
                          onPressed: () => _addMockDistance(1.0),
                          child: const Text('+1.0 km'),
                        ),
                        OutlinedButton(
                          onPressed: () => _addMockDistance(5.0),
                          child: const Text('+5.0 km'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}