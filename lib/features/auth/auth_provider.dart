import 'package:flutter/material.dart';

class AuthState {
  final String? userId;
  final String? nickname;
  final String role; // 'USER' 또는 'ADMIN'
  final int failCount;
  final bool isLocked;

  const AuthState({
    this.userId,
    this.nickname,
    this.role = 'USER',
    this.failCount = 0,
    this.isLocked = false,
  });

  AuthState copyWith({
    String? userId,
    String? nickname,
    String? role,
    int? failCount,
    bool? isLocked,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      role: role ?? this.role,
      failCount: failCount ?? this.failCount,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class AuthController extends ChangeNotifier {
  AuthState _state = const AuthState();
  AuthState get state => _state;

  // 테스트용 임시 로그인 (나중에 실제 API 연동으로 교체)
  void mockLogin({required String nickname, required String role}) {
    if (_state.isLocked) return;
    _state = _state.copyWith(
      userId: 'user_01',
      nickname: nickname,
      role: role,
      failCount: 0,
      isLocked: false,
    );
    notifyListeners();
  }

  // 테스트용 로그인 실패 시뮬레이션 (5회 이상 시 잠금)
  void mockLoginFail() {
    if (_state.isLocked) return;
    final nextFail = _state.failCount + 1;
    _state = _state.copyWith(
      failCount: nextFail,
      isLocked: nextFail >= 5,
    );
    notifyListeners();
  }

  void unlockForTest() {
    _state = const AuthState();
    notifyListeners();
  }
}