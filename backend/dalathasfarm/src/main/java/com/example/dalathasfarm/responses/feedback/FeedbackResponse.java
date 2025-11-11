package com.example.dalathasfarm.responses.feedback;

import com.example.dalathasfarm.models.Feedback;
import com.example.dalathasfarm.responses.BaseResponse;
import com.example.dalathasfarm.responses.user.UserResponse;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class FeedbackResponse extends BaseResponse {
    private Integer id;
    private UserResponse userResponse;
    private String content;
    private Integer star;
    private Integer productId;

    public static FeedbackResponse fromFeedback(Feedback feedback)
    {
        FeedbackResponse newFeedbackResponse = FeedbackResponse.builder()
                .id(feedback.getId())
                .userResponse(UserResponse.fromUser(feedback.getUser()))
                .content(feedback.getContent())
                .star(feedback.getStar())
                .productId(feedback.getProduct().getId())
                .build();
        newFeedbackResponse.setCreatedAt(feedback.getCreatedAt());
        newFeedbackResponse.setUpdatedAt(feedback.getUpdatedAt());

        return newFeedbackResponse;
    }
}
