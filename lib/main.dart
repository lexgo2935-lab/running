import 'package:flutter/material.dart';
import 'core/run_raid_store.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/mypage/mypage_screen.dart';
import 'features/raid/raid_screen.dart';
import 'features/running/running_screen.dart';

void main() {
  runApp(const RunRaidApp());
}

class RunRaidApp extends StatefulWidget {
  const RunRaidApp({super.key});

  @override
  State<RunRaidApp> createState() => _RunRaidAppState();
}

class _RunRaidAppState extends State<RunRaidApp> {
  final AuthController _authController = AuthController();
  final RunRaidStore _store = RunRaidStore();

  @override
  void dispose() {
    _authController.dispose();
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RUN RAID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MainEntryScreen(
        authController: _authController,
        store: _store,
      ),
    );
  }
}

class MainEntryScreen extends StatefulWidget {
  final AuthController authController;
  final RunRaidStore store;

  const MainEntryScreen({
    super.key,
    required this.authController,
    required this.store,
  });

  @override
  State<MainEntryScreen> createState() => _MainEntryScreenState();
}

class _MainEntryScreenState extends State<MainEntryScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      LoginScreen(
        authController: widget.authController,
        onLoginSuccess: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      RaidScreen(
        authController: widget.authController,
        store: widget.store,
      ),
      RunningScreen(store: widget.store),
      MyPageScreen(
        authController: widget.authController,
        store: widget.store,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.login),
            label: '로그인',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_moon),
            label: '레이드',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_run),
            label: '러닝',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}