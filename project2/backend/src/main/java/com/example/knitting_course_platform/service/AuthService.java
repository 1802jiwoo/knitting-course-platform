package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.LoginRequest;
import com.example.knitting_course_platform.dto.LoginResponse;
import com.example.knitting_course_platform.dto.SignUpRequest;
import com.example.knitting_course_platform.dto.SignUpResult;
import com.example.knitting_course_platform.dto.TokenRefreshRequest;
import com.example.knitting_course_platform.dto.TokenRefreshResponse;
import com.example.knitting_course_platform.entity.RefreshToken;
import com.example.knitting_course_platform.entity.User;
import com.example.knitting_course_platform.exception.AccountSuspendedException;
import com.example.knitting_course_platform.exception.DuplicateEmailException;
import com.example.knitting_course_platform.exception.DuplicateNicknameException;
import com.example.knitting_course_platform.repository.RefreshTokenRepository;
import com.example.knitting_course_platform.repository.UserRepository;
import com.example.knitting_course_platform.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d).{8,64}$");
    private static final Pattern NICKNAME_PATTERN =
            Pattern.compile("^[A-Za-z0-9가-힣]{2,20}$");

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    @Transactional
    public SignUpResult signUp(SignUpRequest req) {
        if (!PASSWORD_PATTERN.matcher(req.getPassword()).matches()) {
            throw new IllegalArgumentException("비밀번호는 영문과 숫자를 포함하여 8자 이상이어야 합니다");
        }

        if (!NICKNAME_PATTERN.matcher(req.getNickname()).matches()) {
            throw new IllegalArgumentException("닉네임은 2~20자이며 특수문자를 포함할 수 없습니다");
        }

        if (userRepository.existsByEmail(req.getEmail())) {
            throw new DuplicateEmailException("이미 사용 중인 이메일입니다");
        }

        if (userRepository.existsByNickname(req.getNickname())) {
            throw new DuplicateNicknameException("이미 사용 중인 닉네임입니다");
        }

        User user = User.create(
                req.getEmail(),
                passwordEncoder.encode(req.getPassword()),
                req.getNickname()
        );
        userRepository.save(user);

        return new SignUpResult(user.getUserId(), user.getEmail(), user.getNickname(), user.getRole());
    }

    @Transactional
    public LoginResponse login(LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail())
                .orElseThrow(() -> new IllegalStateException("이메일 또는 비밀번호가 올바르지 않습니다"));

        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new IllegalStateException("이메일 또는 비밀번호가 올바르지 않습니다");
        }

        if (user.isDeleted()) {
            throw new IllegalStateException("이메일 또는 비밀번호가 올바르지 않습니다");
        }

        if (user.isSuspended()) {
            throw new AccountSuspendedException("정지된 계정입니다. 관리자에게 문의하세요");
        }

        refreshTokenRepository.deleteByUserId(user.getUserId());

        String accessToken = jwtUtil.generateAccessToken(user.getUserId(), user.getRole());
        String refreshToken = jwtUtil.generateRefreshToken(user.getUserId());

        refreshTokenRepository.save(
                RefreshToken.create(user.getUserId(), refreshToken, jwtUtil.getRefreshTokenExpiry())
        );

        return new LoginResponse(user.getUserId(), user.getNickname(), user.getRole(), accessToken, refreshToken);
    }

    @Transactional
    public void logout(Long userId) {
        refreshTokenRepository.deleteByUserId(userId);
    }

    @Transactional
    public TokenRefreshResponse refresh(TokenRefreshRequest req) {
        RefreshToken stored = refreshTokenRepository.findByToken(req.getRefreshToken())
                .orElseThrow(() -> new IllegalStateException("다시 로그인해 주세요"));

        if (stored.getExpiresAt().isBefore(java.time.LocalDateTime.now())) {
            refreshTokenRepository.delete(stored);
            throw new IllegalStateException("다시 로그인해 주세요");
        }

        Long userId = stored.getUserId();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException("다시 로그인해 주세요"));

        refreshTokenRepository.deleteByTokenId(stored.getTokenId());

        String newAccessToken = jwtUtil.generateAccessToken(userId, user.getRole());
        String newRefreshToken = jwtUtil.generateRefreshToken(userId);

        refreshTokenRepository.save(
                RefreshToken.create(userId, newRefreshToken, jwtUtil.getRefreshTokenExpiry())
        );

        return new TokenRefreshResponse(newAccessToken, newRefreshToken);
    }
}
