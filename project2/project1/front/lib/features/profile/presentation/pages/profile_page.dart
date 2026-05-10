import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../instructor_application/presentation/providers/instructor_application_state.dart';
import '../providers/profile_state.dart';
import '../../../lecture_manage/presentation/providers/lecture_manage_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileState>().loadProfile();
      context.read<InstructorApplicationState>().loadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileState>();

    return Scaffold(
      appBar: AppBar(title: const Text('내 프로필')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state.isLoading && state.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.profile == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error ?? '프로필을 불러올 수 없습니다.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<ProfileState>().loadProfile(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final profile = state.profile!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 프로필 정보 카드
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: '이메일', value: profile.email),
                    const Divider(height: 24),
                    _InfoRow(label: '닉네임', value: profile.nickname),
                    const Divider(height: 24),
                    _InfoRow(label: '역할', value: _roleLabel(profile.role)),
                    const Divider(height: 24),
                    _InfoRow(
                      label: '가입일',
                      value:
                          '${profile.createdAt.year}.${profile.createdAt.month.toString().padLeft(2, '0')}.${profile.createdAt.day.toString().padLeft(2, '0')}',
                    ),
                    if (profile.role == 'INSTRUCTOR') ...[
                      const Divider(height: 24),
                      _InfoRow(
                        label: '자기소개',
                        value: profile.bio?.isNotEmpty == true
                            ? profile.bio!
                            : '(없음)',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 강의 관리 버튼 (INSTRUCTOR 역할)
              if (profile.role == 'INSTRUCTOR') ...[
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<LectureManageState>().loadMyLectures();
                    Navigator.pushNamed(context, AppRouter.instructorLectures);
                  },
                  icon: const Icon(Icons.video_library_outlined, size: 18),
                  label: const Text('내 강의 관리'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // 강사 신청 섹션 (STUDENT 또는 PENDING 상태일 때)
              if (profile.role == 'STUDENT') _InstructorApplicationSection(
                onApply: _showApplyDialog,
                onCancel: _showCancelConfirmDialog,
              ),

              const SizedBox(height: 8),

              // 프로필 수정
              ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () => _showEditProfileDialog(profile.nickname, profile.bio),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('프로필 수정'),
              ),
              const SizedBox(height: 12),

              // 비밀번호 변경
              OutlinedButton(
                onPressed: state.isLoading ? null : _showChangePasswordDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('비밀번호 변경'),
              ),
              const SizedBox(height: 32),

              // 회원 탈퇴
              TextButton(
                onPressed: state.isLoading ? null : _showDeleteAccountDialog,
                child: const Text(
                  '회원 탈퇴',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 강사 신청 다이얼로그 ─────────────────────────────────────────────

  void _showApplyDialog() {
    final bioCtrl = TextEditingController();
    final planCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('강사 신청'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bioCtrl,
                decoration: const InputDecoration(
                  labelText: '자기소개 *',
                  hintText: '최대 500자',
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: planCtrl,
                decoration: const InputDecoration(
                  labelText: '강의 계획 *',
                  hintText: '최대 1000자',
                ),
                maxLines: 4,
                maxLength: 1000,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (bioCtrl.text.trim().isEmpty || planCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('자기소개와 강의 계획을 모두 입력해 주세요.')),
                );
                return;
              }
              final bio = bioCtrl.text.trim();
              final plan = planCtrl.text.trim();
              Navigator.pop(ctx);
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;
                final success = await context
                    .read<InstructorApplicationState>()
                    .apply(bio: bio, teachingPlan: plan);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success
                        ? '강사 신청이 완료되었습니다. 관리자 검토 후 승인됩니다.'
                        : (context.read<InstructorApplicationState>().error ?? '신청 실패')),
                  ));
                }
              });
            },
            child: const Text('신청'),
          ),
        ],
      ),
    ).whenComplete(() async {
      await Future.delayed(Duration(milliseconds: 100));
      bioCtrl.dispose();
      planCtrl.dispose();
    });
  }

  void _showCancelConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('강사 신청 취소'),
        content: const Text('신청을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await context.read<InstructorApplicationState>().cancel();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? '강사 신청이 취소되었습니다.'
                      : (context.read<InstructorApplicationState>().error ?? '취소 실패')),
                ));
              }
            },
            child: const Text('취소하기'),
          ),
        ],
      ),
    );
  }

  // ── 프로필 수정 다이얼로그 ───────────────────────────────────────────

  void _showEditProfileDialog(String currentNickname, String? currentBio) {
    final nicknameCtrl = TextEditingController(text: currentNickname);
    final bioCtrl = TextEditingController(text: currentBio ?? '');
    final profile = context.read<ProfileState>().profile!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('프로필 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nicknameCtrl,
              decoration: const InputDecoration(
                labelText: '닉네임',
                hintText: '2~20자, 특수문자 불가',
              ),
            ),
            if (profile.role == 'INSTRUCTOR') ...[
              const SizedBox(height: 14),
              TextField(
                controller: bioCtrl,
                decoration: const InputDecoration(
                  labelText: '자기소개',
                  hintText: '최대 500자',
                ),
                maxLines: 3,
                maxLength: 500,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nickname = nicknameCtrl.text.trim();
              final bio =
                  profile.role == 'INSTRUCTOR' ? bioCtrl.text.trim() : null;
              Navigator.pop(ctx);
              final success = await context.read<ProfileState>().updateProfile(
                    nickname: nickname.isNotEmpty ? nickname : null,
                    bio: bio,
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? '프로필이 수정되었습니다.'
                      : (context.read<ProfileState>().error ?? '수정 실패')),
                ));
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    ).whenComplete(() async {
      await Future.delayed(Duration(milliseconds: 100));
      nicknameCtrl.dispose();
      bioCtrl.dispose();
    });
  }

  // ── 비밀번호 변경 다이얼로그 ─────────────────────────────────────────

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('비밀번호 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              decoration: const InputDecoration(labelText: '현재 비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: newCtrl,
              decoration: const InputDecoration(
                labelText: '새 비밀번호',
                hintText: '영문+숫자 조합 8자 이상',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: confirmCtrl,
              decoration: const InputDecoration(labelText: '새 비밀번호 확인'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('새 비밀번호가 일치하지 않습니다.')),
                );
                return;
              }
              final currentPassword = currentCtrl.text;
              final newPassword = newCtrl.text;
              Navigator.pop(ctx);
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;
                final success =
                    await context.read<ProfileState>().changePassword(
                          currentPassword: currentPassword,
                          newPassword: newPassword,
                        );
                if (!mounted) return;
                if (success) {
                  final messenger = ScaffoldMessenger.of(context);
                  await context.read<AuthState>().clearSession();
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRouter.login, (_) => false);
                  messenger.showSnackBar(const SnackBar(
                    content: Text('비밀번호가 변경되었습니다. 다시 로그인해 주세요.'),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        context.read<ProfileState>().error ?? '비밀번호 변경 실패'),
                  ));
                }
              });
            },
            child: const Text('변경'),
          ),
        ],
      ),
    ).whenComplete(() async {
      await Future.delayed(Duration(milliseconds: 100));
      currentCtrl.dispose();
      newCtrl.dispose();
      confirmCtrl.dispose();
    });
  }

  // ── 회원 탈퇴 다이얼로그 ─────────────────────────────────────────────

  void _showDeleteAccountDialog() {
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '탈퇴 시 계정 정보가 비활성화됩니다.\n이 작업은 되돌릴 수 없습니다.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: '비밀번호 확인'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final password = passwordCtrl.text;
              Navigator.pop(ctx);
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;
                final success = await context
                    .read<ProfileState>()
                    .deleteAccount(password: password);
                if (!mounted) return;
                if (success) {
                  final messenger = ScaffoldMessenger.of(context);
                  await context.read<AuthState>().clearSession();
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRouter.login, (_) => false);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('회원 탈퇴가 완료되었습니다.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        context.read<ProfileState>().error ?? '회원 탈퇴 실패'),
                  ));
                }
              });
            },
            child: const Text('탈퇴'),
          ),
        ],
      ),
    ).whenComplete(() async {
        await Future.delayed(Duration(milliseconds: 100));
        passwordCtrl.dispose();
    });
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'STUDENT':
        return '수강생';
      case 'INSTRUCTOR':
        return '강사';
      case 'ADMIN':
        return '관리자';
      default:
        return role;
    }
  }
}

// ── 강사 신청 섹션 위젯 ────────────────────────────────────────────────

class _InstructorApplicationSection extends StatelessWidget {
  final VoidCallback onApply;
  final VoidCallback onCancel;

  const _InstructorApplicationSection({
    required this.onApply,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<InstructorApplicationState>();

    if (appState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final application = appState.application;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: application == null
          ? Row(
              children: [
                const Expanded(
                  child: Text(
                    '강사로 활동하고 싶으신가요?',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                OutlinedButton(
                  onPressed: onApply,
                  child: const Text('강사 신청'),
                ),
              ],
            )
          : Row(
              children: [
                const Icon(Icons.hourglass_top, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '강사 신청 검토 중입니다.',
                    style: TextStyle(fontSize: 13, color: Colors.orange),
                  ),
                ),
                TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    '신청 취소',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── 공통 위젯 ──────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
