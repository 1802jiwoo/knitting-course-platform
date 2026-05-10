package com.example.knitting_course_platform.exception;

public class DuplicateNicknameException extends RuntimeException {
    public DuplicateNicknameException(String message) {
        super(message);
    }
}
