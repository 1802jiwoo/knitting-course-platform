import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/app_state.dart';
import '../providers/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      context.read<AuthState>().clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해 주세요.')),
      );
      return;
    }

    final success = await context.read<AuthState>().login(email, password);
    if (success && mounted) {
      context.read<AppState>().refreshEnrollments();
      Navigator.of(context).pushReplacementNamed(AppRouter.lectureList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'LoopLearn',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  '뜨개질 온라인 강의 플랫폼',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: '이메일'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => auth.clearError(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: '비밀번호'),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  onChanged: (_) => auth.clearError(),
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    auth.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('로그인'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '아직 계정이 없으신가요?',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRouter.register),
                      child: const Text('회원가입', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
