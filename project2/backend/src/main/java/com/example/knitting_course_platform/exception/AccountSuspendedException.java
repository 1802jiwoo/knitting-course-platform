package com.example.knitting_course_platform.exception;

public class AccountSuspendedException extends RuntimeException {
    public AccountSuspendedException(String message) {
        super(message);
    }
}
