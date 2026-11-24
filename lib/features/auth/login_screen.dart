import 'package:flutter/material.dart';
import 'auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.authController,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'USER';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final state = widget.authController.state;
    if (state.isLocked) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // 임시 테스트 규칙: 비밀번호가 '1234'면 로그인 성공, 아니면 실패 카운트 증가
    if (password == '1234') {
      final nick = email.isEmpty ? '러너01' : email.split('@').first;
      widget.authController.mockLogin(
        nickname: nick,
        role: _selectedRole,
      );
      widget.onLoginSuccess();
    } else {
      widget.authController.mockLoginFail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        final state = widget.authController.state;

        return Scaffold(
          appBar: AppBar(title: const Text('RUN RAID 로그인')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  enabled: !state.isLocked,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  enabled: !state.isLocked,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호 (임시 테스트: 1234)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'USER', label: Text('일반 (USER)')),
                    ButtonSegment(value: 'ADMIN', label: Text('관리자 (ADMIN)')),
                  ],
                  selected: {_selectedRole},
                  onSelectionChanged: state.isLocked
                      ? null
                      : (value) {
                          setState(() {
                            _selectedRole = value.first;
                          });
                        },
                ),
                const SizedBox(height: 12),
                if (state.isLocked)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '로그인 5회 실패로 계정이 잠겼습니다.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (state.failCount > 0)
                  Text(
                    '로그인 실패 ${state.failCount}회 / 5회',
                    style: const TextStyle(color: Colors.orange),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.isLocked ? null : _handleLogin,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('로그인'),
                  ),
                ),
                if (state.isLocked) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: widget.authController.unlockForTest,
                    child: const Text('잠금 해제 (테스트용)'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}