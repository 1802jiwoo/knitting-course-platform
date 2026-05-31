import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/enrollment/presentation/pages/my_lectures_page.dart';
import '../../features/lecture/presentation/pages/lecture_detail_page.dart';
import '../../features/lecture/presentation/pages/lecture_list_page.dart';
import '../../features/lecture/presentation/pages/lecture_watch_page.dart';
import '../../features/lecture_manage/presentation/pages/lecture_create_page.dart';
import '../../features/lecture_manage/presentation/pages/lecture_edit_page.dart';
import '../../features/lecture_manage/presentation/pages/my_instructor_lectures_page.dart';
import '../../features/lecture_manage/presentation/pages/lecture_pattern_manage_page.dart';
import '../../features/lecture_manage/presentation/pages/part_manage_page.dart';
import '../../features/lecture_manage/presentation/pages/part_pattern_manage_page.dart';
import '../../features/admin/presentation/pages/admin_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/question/presentation/pages/question_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String lectureList = '/';
  static const String lectureDetail = '/lecture/detail';
  static const String lectureWatch = '/lecture/watch';
  static const String myLectures = '/my-lectures';
  static const String questionDetail = '/question/detail';
  static const String instructorLectures = '/instructor/lectures';
  static const String lectureCreate = '/instructor/lectures/create';
  static const String partManage = '/instructor/lectures/parts';
  static const String lecturePatternManage = '/instructor/lectures/patterns';
  static const String partPatternManage = '/instructor/parts/patterns';
  static const String lectureEdit = '/instructor/lectures/edit';
  static const String admin = '/admin';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case lectureList:
        final args = settings.arguments?.toString() ?? '';
        return MaterialPageRoute(
          builder: (_) => LectureListPage(searchKeyword: args),
        );

      case lectureDetail:
        final lectureId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => LectureDetailPage(lectureId: lectureId),
        );

      case lectureWatch:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LectureWatchPage(
            lectureId: args['lectureId']!,
            partId: args['partId']!,
            lectureTitle: args['lectureTitle'].toString(),
          ),
        );

      case myLectures:
        return MaterialPageRoute(builder: (_) => const MyLecturesPage());

      case questionDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuestionPage(
            lectureTitle: args['lectureTitle'].toString(),
            lectureId: args['lectureId'] as int,
          ),
        );

      case instructorLectures:
        return MaterialPageRoute(
          builder: (_) => const MyInstructorLecturesPage(),
        );

      case lectureCreate:
        return MaterialPageRoute(
          builder: (_) => const LectureCreatePage(),
        );

      case partManage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PartManagePage(
            lectureId: args['lectureId'] as int,
            lectureTitle: args['lectureTitle'] as String,
          ),
        );

      case lecturePatternManage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LecturePatternManagePage(
            lectureId: args['lectureId'] as int,
            lectureTitle: args['lectureTitle'] as String,
          ),
        );

      case partPatternManage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PartPatternManagePage(
            partId: args['partId'] as int,
            partTitle: args['partTitle'] as String,
          ),
        );

      case lectureEdit:
        final lecture = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (_) => LectureEditPage(lecture: lecture),
        );

      case admin:
        return MaterialPageRoute(builder: (_) => const AdminPage());

      default:
        return MaterialPageRoute(builder: (_) => const LectureListPage());
    }
  }
}
