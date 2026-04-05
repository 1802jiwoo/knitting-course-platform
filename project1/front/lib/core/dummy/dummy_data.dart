import '../../features/lecture/domain/entities/lecture.dart';
import '../../features/lecture/domain/entities/lecture_part.dart';
import '../../features/lecture/domain/entities/lecture_pattern.dart';
import '../../features/lecture/domain/entities/part_pattern.dart';
import '../../features/lecture/domain/entities/tag.dart';
import '../../features/lecture/domain/entities/video.dart';
import '../../features/question/domain/entities/question.dart';
import '../../features/question/domain/entities/answer.dart';

// ── 태그 ──────────────────────────────────────────────────────
final List<Tag> dummyTags = [
  const Tag(tagId: 1, tagName: '초보'),
  const Tag(tagId: 2, tagName: '뜨개질'),
  const Tag(tagId: 3, tagName: 'DIY'),
  const Tag(tagId: 4, tagName: '인형'),
  const Tag(tagId: 5, tagName: '가방'),
  const Tag(tagId: 6, tagName: '소품'),
  const Tag(tagId: 7, tagName: '뜨개기법'),
];

// ── 강의 ──────────────────────────────────────────────────────
final List<Lecture> dummyLectures = [
  // Lecture(lectureId: 1, title: '기초 뜨개질', description: '초보자를 위한 뜨개질 강의입니다. 기초 기법을 단계별로 익히고 나만의 작품을 완성해 보세요.', lectureType: 'BASIC', instructorName: '강사님', createdAt: DateTime(2026, 3, 1)),
  // Lecture(lectureId: 2, title: '귀여운 인형 만들기', description: '단계별로 따라 하면 누구나 만들 수 있는 뜨개 인형 강의입니다.', lectureType: 'PROJECT', instructorName: '강사님', createdAt: DateTime(2026, 3, 5)),
  // Lecture(lectureId: 3, title: '미니 가방 도안', description: '영상 없이 도안만으로 제작하는 미니 가방입니다.', lectureType: 'PATTERN', instructorName: '강사님', createdAt: DateTime(2026, 3, 8)),
  // Lecture(lectureId: 4, title: '겉뜨기 · 안뜨기', description: '뜨개질의 기본인 겉뜨기와 안뜨기를 마스터합니다.', lectureType: 'BASIC', instructorName: '강사님', createdAt: DateTime(2026, 3, 10)),
  // Lecture(lectureId: 5, title: '뜨개 모자 완성하기', description: '겨울 시즌에 딱 맞는 뜨개 모자 제작 과정입니다.', lectureType: 'PROJECT', instructorName: '강사님', createdAt: DateTime(2026, 3, 12)),
  // Lecture(lectureId: 6, title: '곰돌이 인형 도안', description: '귀여운 곰돌이 인형을 도안으로 제작합니다.', lectureType: 'PATTERN', instructorName: '강사님', createdAt: DateTime(2026, 3, 14)),
];

// ── 강의-태그 매핑 ────────────────────────────────────────────
final Map<int, List<int>> dummyLectureTagIds = {
  1: [1, 2], 2: [4, 3], 3: [5, 6],
  4: [7, 1], 5: [6, 3], 6: [4, 6],
};

List<Tag> getTagsForLecture(int lectureId) {
  final ids = dummyLectureTagIds[lectureId] ?? [];
  return dummyTags.where((t) => ids.contains(t.tagId)).toList();
}

// ── 강의 파트 ─────────────────────────────────────────────────
final List<LecturePart> dummyParts = [
  const LecturePart(partId: 1,  lectureId: 1, title: '코 잡기',       orderNo: 1),
  const LecturePart(partId: 2,  lectureId: 1, title: '기본 뜨기',     orderNo: 2),
  const LecturePart(partId: 3,  lectureId: 2, title: '머리 만들기',   orderNo: 1),
  const LecturePart(partId: 4,  lectureId: 2, title: '팔 만들기',     orderNo: 2),
  const LecturePart(partId: 5,  lectureId: 2, title: '다리 만들기',   orderNo: 3),
  const LecturePart(partId: 6,  lectureId: 2, title: '몸통 만들기',   orderNo: 4),
  const LecturePart(partId: 7,  lectureId: 2, title: '바느질 및 조립', orderNo: 5),
  const LecturePart(partId: 8,  lectureId: 4, title: '겉뜨기 기초',   orderNo: 1),
  const LecturePart(partId: 9,  lectureId: 4, title: '안뜨기 기초',   orderNo: 2),
  const LecturePart(partId: 10, lectureId: 4, title: '응용 패턴',     orderNo: 3),
  const LecturePart(partId: 11, lectureId: 5, title: '코 잡기 및 시작', orderNo: 1),
  const LecturePart(partId: 12, lectureId: 5, title: '몸통 뜨기',     orderNo: 2),
  const LecturePart(partId: 13, lectureId: 5, title: '테두리 마감',   orderNo: 3),
];

List<LecturePart> getPartsForLecture(int lectureId) =>
    dummyParts.where((p) => p.lectureId == lectureId).toList()
      ..sort((a, b) => a.orderNo.compareTo(b.orderNo));

// ── 영상 ──────────────────────────────────────────────────────
final List<Video> dummyVideos = [
  const Video(videoId: 1,  partId: 1,  youtubeUrl: 'https://youtube.com/embed/example1',  duration: 300),
  const Video(videoId: 2,  partId: 2,  youtubeUrl: 'https://youtube.com/embed/example2',  duration: 600),
  const Video(videoId: 3,  partId: 3,  youtubeUrl: 'https://youtube.com/embed/example3',  duration: 480),
  const Video(videoId: 4,  partId: 4,  youtubeUrl: 'https://youtube.com/embed/example4',  duration: 360),
  const Video(videoId: 5,  partId: 5,  youtubeUrl: 'https://youtube.com/embed/example5',  duration: 420),
  const Video(videoId: 6,  partId: 6,  youtubeUrl: 'https://youtube.com/embed/example6',  duration: 540),
  const Video(videoId: 7,  partId: 7,  youtubeUrl: 'https://youtube.com/embed/example7',  duration: 660),
  const Video(videoId: 8,  partId: 8,  youtubeUrl: 'https://youtube.com/embed/example8',  duration: 300),
  const Video(videoId: 9,  partId: 9,  youtubeUrl: 'https://youtube.com/embed/example9',  duration: 300),
  const Video(videoId: 10, partId: 10, youtubeUrl: 'https://youtube.com/embed/example10', duration: 400),
  const Video(videoId: 11, partId: 11, youtubeUrl: 'https://youtube.com/embed/example11', duration: 350),
  const Video(videoId: 12, partId: 12, youtubeUrl: 'https://youtube.com/embed/example12', duration: 500),
  const Video(videoId: 13, partId: 13, youtubeUrl: 'https://youtube.com/embed/example13', duration: 280),
];

Video? getVideoForPart(int partId) {
  try { return dummyVideos.firstWhere((v) => v.partId == partId); }
  catch (_) { return null; }
}

// ── 파트 도안 (영상 연동) ────────────────────────────────────
final List<PartPattern> dummyPartPatterns = [
  const PartPattern(patternId: 1, partId: 1, startTime: 0,   endTime: 60,  rowNum: 1, patternText: '코 20개 잡기'),
  const PartPattern(patternId: 2, partId: 1, startTime: 60,  endTime: 120, rowNum: 2, patternText: 'sc 10회 반복'),
  const PartPattern(patternId: 3, partId: 1, startTime: 120, endTime: 180, rowNum: 3, patternText: 'inc 2회, sc 8회'),
  const PartPattern(patternId: 4, partId: 1, startTime: 180, endTime: 300, rowNum: 4, patternText: '모두 겉뜨기'),
  const PartPattern(patternId: 5, partId: 2, startTime: 0,   endTime: 120, rowNum: 1, patternText: 'sc 12회'),
  const PartPattern(patternId: 6, partId: 2, startTime: 120, endTime: 300, rowNum: 2, patternText: 'inc 6회 (18코)'),
  const PartPattern(patternId: 7, partId: 2, startTime: 300, endTime: 600, rowNum: 3, patternText: 'sc 18회 × 3단'),
];

List<PartPattern> getPatternsForPart(int partId) =>
    dummyPartPatterns.where((p) => p.partId == partId).toList()
      ..sort((a, b) => a.rowNum.compareTo(b.rowNum));

// ── 강의 단위 도안 (PATTERN 유형) ────────────────────────────
final List<LecturePattern> dummyLecturePatterns = [
  const LecturePattern(patternId: 1, lectureId: 3, rowNum: 1, patternText: 'ch 20, turn'),
  const LecturePattern(patternId: 2, lectureId: 3, rowNum: 2, patternText: 'sc 20, ch1, turn'),
  const LecturePattern(patternId: 3, lectureId: 3, rowNum: 3, patternText: 'sc 20, ch1, turn'),
  const LecturePattern(patternId: 4, lectureId: 3, rowNum: 4, patternText: 'sl st 마감'),
  const LecturePattern(patternId: 5, lectureId: 6, rowNum: 1, patternText: 'mc 6sc'),
  const LecturePattern(patternId: 6, lectureId: 6, rowNum: 2, patternText: 'inc × 6 (12코)'),
  const LecturePattern(patternId: 7, lectureId: 6, rowNum: 3, patternText: '(sc, inc) × 6 (18코)'),
  const LecturePattern(patternId: 8, lectureId: 6, rowNum: 4, patternText: 'sc × 18 × 3단'),
];

List<LecturePattern> getLecturePatternsForLecture(int lectureId) =>
    dummyLecturePatterns.where((p) => p.lectureId == lectureId).toList()
      ..sort((a, b) => a.rowNum.compareTo(b.rowNum));

// ── 질문 ──────────────────────────────────────────────────────
final List<Question> dummyQuestions = [
  // Question(questionId: 1, userId: 1, lectureId: 1, title: '코 잡기 질문', content: '코가 자꾸 풀려요. 처음에 너무 느슨하게 잡은 걸까요? 어떻게 해야 단단하게 잡을 수 있나요?', imageUrl: null, createdAt: DateTime(2026, 3, 10)),
  // Question(questionId: 2, userId: 1, lectureId: 1, title: '기본 뜨기가 잘 안돼요', content: '영상을 따라 해봤는데 모양이 이상하게 나와요. 코가 뒤틀리는 것 같기도 하고, 어디서부터 잘못된 건지 모르겠어요.', imageUrl: null, createdAt: DateTime(2026, 3, 9)),
  // Question(questionId: 3, userId: 1, lectureId: 2, title: '인형 머리 모양이 이상해요', content: '머리가 너무 납작하게 나와요. 솜을 충분히 넣었는데도 동그랗게 안 되는 이유가 있을까요?', imageUrl: null, createdAt: DateTime(2026, 3, 11)),
];

List<Question> getQuestionsForLecture(int lectureId) {
  final list = dummyQuestions.where((q) => q.lectureId == lectureId).toList();
  list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return list;
}

Question? getQuestionById(int questionId) {
  try { return dummyQuestions.firstWhere((q) => q.questionId == questionId); }
  catch (_) { return null; }
}

// ── 답변 (강사 작성 — P1에서는 읽기 전용으로 표시) ───────────
// final List<Answer> dummyAnswers = [
//   Answer(
//     answerId: 1,
//     questionId: 1,
//     instructorId: 2,
//     content: '처음에 너무 느슨하게 잡으신 것 같아요. 코를 잡을 때 실을 엄지와 검지로 팽팽하게 잡아주시고, 바늘에 감는 힘을 일정하게 유지해 주세요. 처음 몇 코는 풀리기 쉬우니 꼬리실을 충분히 남겨두시면 도움이 됩니다!',
//     createdAt: DateTime(2026, 3, 11),
//   ),
//   Answer(
//     answerId: 2,
//     questionId: 3,
//     instructorId: 2,
//     content: '솜을 넣는 타이밍이 중요해요. 완전히 닫기 전 마지막 2~3단 남았을 때부터 솜을 조금씩 넣으면서 모양을 잡아주세요. 한 번에 다 넣으려 하면 납작해지기 쉽답니다. 솜도 가운데부터 채워주시면 훨씬 동그랗게 나와요!',
//     createdAt: DateTime(2026, 3, 12),
//   ),
// ];
//
// List<Answer> getAnswersForQuestion(int questionId) =>
//     dummyAnswers.where((a) => a.questionId == questionId).toList()
//       ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
