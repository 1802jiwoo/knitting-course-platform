package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.ChangePasswordRequest;
import com.example.knitting_course_platform.dto.DeleteAccountRequest;
import com.example.knitting_course_platform.dto.ProfileResponse;
import com.example.knitting_course_platform.dto.ProfileUpdateRequest;
import com.example.knitting_course_platform.service.ProfileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping("/me")
    public ProfileResponse getMyProfile(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        return profileService.getMyProfile(userId);
    }

    @PatchMapping("/me")
    public ProfileResponse updateProfile(Authentication authentication,
                                         @Valid @RequestBody ProfileUpdateRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        return profileService.updateProfile(userId, request);
    }

    @PatchMapping("/password")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void changePassword(Authentication authentication,
                               @Valid @RequestBody ChangePasswordRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        profileService.changePassword(userId, request);
    }

    @DeleteMapping("/me")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteAccount(Authentication authentication,
                              @Valid @RequestBody DeleteAccountRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        profileService.deleteAccount(userId, request);
    }
}
