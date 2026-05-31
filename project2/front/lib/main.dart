import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/state/app_state.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/providers/auth_state.dart';
import 'features/instructor_application/data/repositories/instructor_application_repository_impl.dart';
import 'features/instructor_application/domain/repositories/instructor_application_repository.dart';
import 'features/instructor_application/presentation/providers/instructor_application_state.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/providers/profile_state.dart';
import 'features/enrollment/data/repositories/enrollment_repository_impl.dart';
import 'features/enrollment/domain/repositories/enrollment_repository.dart';
import 'features/lecture/data/repositories/lecture_repository_impl.dart';
import 'features/lecture/domain/repositories/lecture_repository.dart';
import 'features/lecture_manage/data/repositories/lecture_manage_repository_impl.dart';
import 'features/lecture_manage/data/repositories/lecture_pattern_manage_repository_impl.dart';
import 'features/lecture_manage/data/repositories/part_manage_repository_impl.dart';
import 'features/lecture_manage/data/repositories/part_pattern_manage_repository_impl.dart';
import 'features/lecture_manage/domain/repositories/lecture_manage_repository.dart';
import 'features/lecture_manage/domain/repositories/lecture_pattern_manage_repository.dart';
import 'features/lecture_manage/domain/repositories/part_manage_repository.dart';
import 'features/lecture_manage/domain/repositories/part_pattern_manage_repository.dart';
import 'features/lecture_manage/presentation/providers/lecture_manage_state.dart';
import 'features/lecture_manage/presentation/providers/lecture_pattern_manage_state.dart';
import 'features/lecture_manage/presentation/providers/part_manage_state.dart';
import 'features/lecture_manage/presentation/providers/part_pattern_manage_state.dart';

import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/presentation/providers/admin_state.dart';
import 'features/question/data/repositories/answer_repository_impl.dart';
import 'features/question/data/repositories/question_repository_impl.dart';
import 'features/question/domain/repositories/answer_repository.dart';
import 'features/question/domain/repositories/question_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final tokenStorage = TokenStorage(prefs);
  final isLoggedIn = tokenStorage.accessToken != null;

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStorage>(create: (_) => tokenStorage),
        Provider<ApiClient>(
          create: (_) => ApiClient(tokenStorage: tokenStorage),
        ),
        ProxyProvider<ApiClient, LectureRepository>(
          update: (_, api, __) => LectureRepositoryImpl(api: api),
        ),
        ProxyProvider<ApiClient, QuestionRepository>(
          update: (_, api, __) => QuestionRepositoryImpl(api: api),
        ),
        ProxyProvider<ApiClient, AnswerRepository>(
          update: (_, api, __) => AnswerRepositoryImpl(api: api),
        ),
        ProxyProvider<ApiClient, EnrollmentRepository>(
          update: (_, api, __) => EnrollmentRepositoryImpl(api: api),
        ),
        ChangeNotifierProxyProvider<EnrollmentRepository, AppState>(
          create: (ctx) => AppState(
            repo: Provider.of<EnrollmentRepository>(ctx, listen: false),
            storage: tokenStorage,
          ),
          update: (_, __, prev) => prev!,
        ),
        ProxyProvider<ApiClient, AuthRepository>(
          update: (_, api, __) =>
              AuthRepositoryImpl(api: api, storage: tokenStorage),
        ),
        ChangeNotifierProxyProvider<AuthRepository, AuthState>(
          create: (ctx) => AuthState(
            repo: Provider.of<AuthRepository>(ctx, listen: false),
            storage: tokenStorage,
          ),
          update: (_, __, prev) => prev!,
        ),
        ProxyProvider<ApiClient, ProfileRepository>(
          update: (_, api, __) => ProfileRepositoryImpl(api: api),
        ),
        ChangeNotifierProxyProvider<ProfileRepository, ProfileState>(
          create: (ctx) => ProfileState(
            repo: Provider.of<ProfileRepository>(ctx, listen: false),
          ),
          update: (_, __, prev) => prev!,
        ),
        ProxyProvider<ApiClient, InstructorApplicationRepository>(
          update: (_, api, __) =>
              InstructorApplicationRepositoryImpl(api: api),
        ),
        ChangeNotifierProxyProvider<InstructorApplicationRepository,
            InstructorApplicationState>(
          create: (ctx) => InstructorApplicationState(
            repo: Provider.of<InstructorApplicationRepository>(
                ctx, listen: false),
          ),
          update: (_, __, prev) => prev!,
        ),
        ProxyProvider<ApiClient, AdminRepository>(
          update: (_, api, __) => AdminRepositoryImpl(api: api),
        ),
        ChangeNotifierProxyProvider<AdminRepository, AdminState>(
          create: (ctx) => AdminState(
            repo: Provider.of<AdminRepository>(ctx, listen: false),
          ),
          update: (_, __, prev) => prev!,
        ),
        ProxyProvider<ApiClient, LectureManageRepository>(
          update: (_, api, __) => LectureManageRepositoryImpl(api: api),
        ),
        ChangeNotifierProxyProvider<LectureManageRepository,
            LectureManageState>(
          create: (ctx) => LectureManageState(
            repo: Provider.of<LectureManageRepository>(ctx, listen: false),
          ),
          update: (_, __, prev) => prev!,
        ),
        ProxyProvider<ApiClient, PartManageRepository>(
          update: (_, api, __) => PartManageRepositoryImpl(api: api),
        ),
        ChangeNotifierProxyProvider<PartManageRepository, PartManageState>(
          create: (ctx) => PartManageState(
            repo: Provider.of<PartManageRepository>(ctx, listen: false),
          ),
          update: (_, __, prev) => prev!,
        ),
        ProxyProvider<ApiClient, LecturePatternManageRepository>(
          update: (_, api, __) =>
              LecturePatternManageRepositoryImpl(api: api),
        ),
        ChangeNotifierProxyProvider<LecturePatternManageRepository,
            LecturePatternManageState>(
          create: (ctx) => LecturePatternManageState(
            repo: Provider.of<LecturePatternManageRepository>(
                ctx, listen: false),
          ),
          update: (_, __, prev) => prev!,
        ),
        ProxyProvider<ApiClient, PartPatternManageRepository>(
          update: (_, api, __) => PartPatternManageRepositoryImpl(api: api),
        ),
        ChangeNotifierProxyProvider<PartPatternManageRepository,
            PartPatternManageState>(
          create: (ctx) => PartPatternManageState(
            repo: Provider.of<PartPatternManageRepository>(ctx, listen: false),
          ),
          update: (_, __, prev) => prev!,
        ),
      ],
      child: LoopLearnApp(
        initialRoute: isLoggedIn ? AppRouter.lectureList : AppRouter.login,
      ),
    ),
  );
}

class LoopLearnApp extends StatelessWidget {
  final String initialRoute;

  const LoopLearnApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoopLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE0E0E0),
          thickness: 0.5,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            side: const BorderSide(color: Colors.black26),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black87),
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        ),
      ),
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
