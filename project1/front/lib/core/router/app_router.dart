import 'package:flutter/material.dart';
import '../../features/lecture/presentation/pages/lecture_list_page.dart';
import '../../features/lecture/presentation/pages/lecture_detail_page.dart';
import '../../features/lecture/presentation/pages/lecture_watch_page.dart';
import '../../features/enrollment/presentation/pages/my_lectures_page.dart';
import '../../features/question/presentation/pages/question_page.dart';

class AppRouter {
  static const String lectureList = '/';
  static const String lectureDetail = '/lecture/detail';
  static const String lectureWatch = '/lecture/watch';
  static const String myLectures = '/my-lectures';
  static const String questionDetail = '/question/detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case lectureList:
        final args = settings.arguments.toString();
        return MaterialPageRoute(builder: (_) => LectureListPage(
          searchKeyword: args,
        ));

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

      default:
        return MaterialPageRoute(builder: (_) => const LectureListPage());
    }
  }
}
