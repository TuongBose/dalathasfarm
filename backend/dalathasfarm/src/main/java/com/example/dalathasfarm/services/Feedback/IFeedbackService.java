package com.example.dalathasfarm.services.Feedback;

import com.example.dalathasfarm.dtos.FeedbackDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.responses.feedback.FeedbackResponse;

import java.util.List;

public interface IFeedbackService {
    FeedbackResponse insertFeedback(FeedbackDto feedbackDto) throws DataNotFoundException;
    void deleteFeedback(int feedbackId) throws Exception;
    void updateFeedback(FeedbackDto feedbackDto, int feedbackId) throws DataNotFoundException;
    List<FeedbackResponse> getFeedbacksByUser(Integer userId) throws DataNotFoundException;
    List<FeedbackResponse> getFeedbacksByProduct(Integer productId) throws DataNotFoundException;
    List<FeedbackResponse> getFeedbacksByUserAndProduct(Integer userId, Integer productId) throws DataNotFoundException;
}
