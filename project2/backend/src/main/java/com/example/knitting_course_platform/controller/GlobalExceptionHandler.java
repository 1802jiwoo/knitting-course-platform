package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.exception.AccountSuspendedException;
import com.example.knitting_course_platform.exception.DuplicateApplicationException;
import com.example.knitting_course_platform.exception.DuplicateEmailException;
import com.example.knitting_course_platform.exception.DuplicateEnrollmentException;
import com.example.knitting_course_platform.exception.DuplicateNicknameException;
import com.example.knitting_course_platform.exception.ForbiddenException;
import com.example.knitting_course_platform.exception.ResourceNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.resource.NoResourceFoundException;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(DuplicateEmailException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public Map<String, String> handleDuplicateEmail(DuplicateEmailException e) {
        return Map.of("message", e.getMessage());
    }

    @ExceptionHandler(DuplicateNicknameException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public Map<String, String> handleDuplicateNickname(DuplicateNicknameException e) {
        return Map.of("message", e.getMessage());
    }

    @ExceptionHandler(DuplicateApplicationException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public Map<String, String> handleDuplicateApplication(DuplicateApplicationException e) {
        return Map.of("message", e.getMessage());
    }

    @ExceptionHandler(DuplicateEnrollmentException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public Map<String, String> handleDuplicateEnrollment(DuplicateEnrollmentException e) {
        return Map.of("message", e.getMessage());
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public Map<String, String> handleResourceNotFound(ResourceNotFoundException e) {
        return Map.of("message", e.getMessage());
    }

    @ExceptionHandler(ForbiddenException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    public Map<String, String> handleForbidden(ForbiddenException e) {
        return Map.of("message", e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Map<String, String> handleValidation(MethodArgumentNotValidException e) {
        return Map.of("message", "필수 항목을 입력해 주세요");
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Map<String, String> handleBadRequest(IllegalArgumentException e) {
        return Map.of("message", e.getMessage());
    }

    @ExceptionHandler(IllegalStateException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public Map<String, String> handleUnauthorized(IllegalStateException e) {
        return Map.of("message", e.getMessage());
    }

    @ExceptionHandler(AccountSuspendedException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    public Map<String, String> handleSuspended(AccountSuspendedException e) {
        return Map.of("message", e.getMessage());
    }

    @ExceptionHandler(NoResourceFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public Map<String, String> handleNoResource(NoResourceFoundException e) {
        return Map.of("message", "요청한 리소스를 찾을 수 없습니다");
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public Map<String, String> handleGeneral(Exception e) {
        log.error("Unhandled exception", e);
        return Map.of("message", "서버 오류가 발생했습니다.");
    }
}
