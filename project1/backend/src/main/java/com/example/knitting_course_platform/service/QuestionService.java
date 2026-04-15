package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.*;
import com.example.knitting_course_platform.entity.*;
import com.example.knitting_course_platform.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class QuestionService {

    private final QuestionRepository questionRepository;
    private final LectureRepository lectureRepository;
    private final UserRepository userRepository;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Value("${app.base-url:http://10.252.60.21:8080}")
    private String baseUrl;

    // GET /api/lectures/{lectureId}/questions
    @Transactional(readOnly = true)
    public List<QuestionListResponse> getQuestions(Long lectureId) {
        return questionRepository.findByLectureLectureIdOrderByCreatedAtDesc(lectureId)
                .stream()
                .map(QuestionListResponse::from)
                .toList();
    }

    // GET /api/questions/{questionId}
    @Transactional(readOnly = true)
    public QuestionDetailResponse getQuestionDetail(Long questionId) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new IllegalArgumentException("질문을 찾을 수 없습니다: " + questionId));
        return QuestionDetailResponse.from(question);
    }

    // POST /api/questions
    public void createQuestion(QuestionCreateRequest request, MultipartFile image) {
        Lecture lecture = lectureRepository.findById(request.lectureId())
                .orElseThrow(() -> new IllegalArgumentException("강의를 찾을 수 없습니다: " + request.lectureId()));

        Long userId = (request.userId() != null) ? request.userId() : 1L;
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = saveImageFile(image);
        }

        Question question = Question.builder()
                .lecture(lecture)
                .user(user)
                .title(request.title())
                .content(request.content())
                .imageUrl(imageUrl)
                .build();

        questionRepository.save(question);
    }

    /**
     * 이미지 파일을 {uploadDir}/questions/ 에 저장하고 접근 URL을 반환한다.
     * 저장 경로 예: uploads/questions/550e8400-uuid.jpg
     * 반환 URL 예: http://172.28.6.110:8080/uploads/questions/550e8400-uuid.jpg
     */
    private String saveImageFile(MultipartFile image) {
        try {
            String original = image.getOriginalFilename();
            String ext = (original != null && original.contains("."))
                    ? original.substring(original.lastIndexOf('.'))
                    : ".jpg";
            String fileName = UUID.randomUUID() + ext;

            Path dir = Paths.get(uploadDir, "questions");
            Files.createDirectories(dir);
            Files.write(dir.resolve(fileName), image.getBytes());

            return baseUrl + "/uploads/questions/" + fileName;
        } catch (IOException e) {
            throw new IllegalArgumentException("이미지 저장 중 오류가 발생했습니다.");
        }
    }
}
