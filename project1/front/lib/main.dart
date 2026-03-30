import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/state/app_state.dart';
import 'features/lecture/data/repositories/lecture_repository_impl.dart';
import 'features/lecture/domain/repositories/lecture_repository.dart';
import 'features/question/data/repositories/answer_repository_impl.dart';
import 'features/question/data/repositories/question_repository_impl.dart';
import 'features/question/domain/repositories/answer_repository.dart';
import 'features/question/domain/repositories/question_repository.dart';
import 'features/enrollment/data/repositories/enrollment_repository_impl.dart';
import 'features/enrollment/domain/repositories/enrollment_repository.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
        ),
        Provider<ApiClient>(
          create: (_) => ApiClient(),
        ),
        ProxyProvider<ApiClient, LectureRepository>(
          update: (_, api, __) => LectureRepositoryImpl(api: api),
        ),
        ProxyProvider<ApiClient, QuestionRepository>(
          update: (_, api, __) => QuestionRepositoryImpl(api: api),
        ),
        ProxyProvider<ApiClient, AnswerRepository>(      // 추가
          update: (_, api, __) => AnswerRepositoryImpl(api: api),
        ),
        // P2 이후 서버 연동 시 사용
        ProxyProvider<ApiClient, EnrollmentRepository>(
          update: (_, api, __) => EnrollmentRepositoryImpl(api: api),
        ),
      ],
      child: const LoopLearnApp(),
    ),
  );
}

class LoopLearnApp extends StatelessWidget {
  const LoopLearnApp({super.key});

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
      initialRoute: AppRouter.lectureList,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
