package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.ChangePasswordRequest;
import com.example.knitting_course_platform.dto.DeleteAccountRequest;
import com.example.knitting_course_platform.dto.ProfileResponse;
import com.example.knitting_course_platform.dto.ProfileUpdateRequest;
import com.example.knitting_course_platform.entity.User;
import com.example.knitting_course_platform.exception.DuplicateNicknameException;
import com.example.knitting_course_platform.repository.RefreshTokenRepository;
import com.example.knitting_course_platform.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d).{8,64}$");

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public ProfileResponse getMyProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다"));
        return new ProfileResponse(user);
    }

    @Transactional
    public ProfileResponse updateProfile(Long userId, ProfileUpdateRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다"));

        String newNickname = request.getNickname();
        if (newNickname != null && !newNickname.equals(user.getNickname())) {
            if (userRepository.existsByNickname(newNickname)) {
                throw new DuplicateNicknameException("이미 사용 중인 닉네임입니다");
            }
        }

        user.updateProfile(newNickname, request.getBio());

        return new ProfileResponse(user);
    }

    @Transactional
    public void changePassword(Long userId, ChangePasswordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다"));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new IllegalArgumentException("현재 비밀번호가 올바르지 않습니다");
        }

        if (!PASSWORD_PATTERN.matcher(request.getNewPassword()).matches()) {
            throw new IllegalArgumentException("비밀번호는 영문과 숫자를 포함하여 8자 이상이어야 합니다");
        }

        if (passwordEncoder.matches(request.getNewPassword(), user.getPassword())) {
            throw new IllegalArgumentException("현재 비밀번호와 동일한 비밀번호로 변경할 수 없습니다");
        }

        user.changePassword(passwordEncoder.encode(request.getNewPassword()));
        refreshTokenRepository.deleteByUserId(userId);
    }

    @Transactional
    public void deleteAccount(Long userId, DeleteAccountRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("비밀번호가 올바르지 않습니다");
        }

        user.delete();
        refreshTokenRepository.deleteByUserId(userId);
    }
}
