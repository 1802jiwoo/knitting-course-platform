package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "ENROLLMENT_PART", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"enrollment_id", "part_id"})
})
@Getter
@NoArgsConstructor
public class EnrollmentPart {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "enrollment_id", nullable = false)
    private Enrollment enrollment;

    @Column(name = "part_id", nullable = false)
    private Long partId;

    @Column(name = "completed_at", nullable = false)
    private LocalDateTime completedAt;

    public static EnrollmentPart create(Enrollment enrollment, Long partId) {
        EnrollmentPart ep = new EnrollmentPart();
        ep.enrollment = enrollment;
        ep.partId = partId;
        ep.completedAt = LocalDateTime.now();
        return ep;
    }
}
