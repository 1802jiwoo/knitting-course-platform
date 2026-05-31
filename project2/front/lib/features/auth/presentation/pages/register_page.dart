import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nicknameCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailCtrl.text.trim();
    final nickname = _nicknameCtrl.text.trim();
    final password = _passwordCtrl.text;
    final passwordConfirm = _passwordConfirmCtrl.text;

    if (email.isEmpty || nickname.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 입력해 주세요.')),
      );
      return;
    }

    if (password != passwordConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    final success =
        await context.read<AuthState>().register(email, password, nickname);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인해 주세요.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: '이메일 *'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => auth.clearError(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nicknameCtrl,
                  decoration: const InputDecoration(
                    labelText: '닉네임 *',
                    hintText: '2~20자, 특수문자 불가',
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => auth.clearError(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(
                    labelText: '비밀번호 *',
                    hintText: '영문+숫자 조합 8자 이상',
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordConfirmCtrl,
                  decoration: const InputDecoration(labelText: '비밀번호 확인 *'),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _register(),
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
                  onPressed: auth.isLoading ? null : _register,
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
                      : const Text('회원가입'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '이미 계정이 있으신가요?',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('로그인', style: TextStyle(fontSize: 13)),
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
