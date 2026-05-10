package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class InstructorApplicationRequest {

    @NotBlank
    @Size(max = 500)
    private String bio;

    @NotBlank
    @Size(max = 1000)
    private String teachingPlan;
}
