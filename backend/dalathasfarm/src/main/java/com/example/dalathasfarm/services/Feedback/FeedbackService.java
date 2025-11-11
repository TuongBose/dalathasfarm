package com.example.dalathasfarm.services.Feedback;

import com.example.dalathasfarm.dtos.FeedbackDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.Feedback;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.repositories.FeedbackRepository;
import com.example.dalathasfarm.repositories.ProductRepository;
import com.example.dalathasfarm.repositories.UserRepository;
import com.example.dalathasfarm.responses.feedback.FeedbackResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FeedbackService implements IFeedbackService{
    private final FeedbackRepository feedbackRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    @Override
    @Transactional
    public FeedbackResponse insertFeedback(FeedbackDto feedbackDto) throws DataNotFoundException {
        User existingUser = userRepository.findById(feedbackDto.getUserId())
                .orElseThrow(() -> new DataNotFoundException("User not found"));

        Product existingProduct = productRepository.findById(feedbackDto.getProductId())
                .orElseThrow(() -> new DataNotFoundException("Product not found"));

        Feedback newfeedback = Feedback
                .builder()
                .user(existingUser)
                .star(feedbackDto.getStar())
                .content(feedbackDto.getContent())
                .product(existingProduct)
                .build();
        feedbackRepository.save(newfeedback);

        return FeedbackResponse.fromFeedback(newfeedback);
    }

    @Override
    @Transactional
    public void deleteFeedback(int feedbackId) throws Exception {
        Feedback existingFeedback = feedbackRepository
                .findById(feedbackId)
                .orElseThrow(()-> new DataNotFoundException("Feedback does not exist"));
        feedbackRepository.deleteById(existingFeedback.getId());
    }

    @Override
    public void updateFeedback(FeedbackDto feedbackDto, int feedbackId) throws DataNotFoundException {
        Feedback existingFeedback = feedbackRepository.findById(feedbackId)
                .orElseThrow(() -> new DataNotFoundException("Feedback not found"));

        User existingUser = userRepository.findById(feedbackDto.getUserId())
                .orElseThrow(() -> new DataNotFoundException("User not found"));

        Product existingProduct = productRepository.findById(feedbackDto.getProductId())
                .orElseThrow(() -> new DataNotFoundException("Product not found"));

        existingFeedback.setContent(feedbackDto.getContent());
        existingFeedback.setStar(feedbackDto.getStar());

        feedbackRepository.save(existingFeedback);
    }

    @Override
    public List<FeedbackResponse> getFeedbacksByUser(Integer userId) throws DataNotFoundException {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new DataNotFoundException("User not found"));

        List<Feedback> feedbacks = feedbackRepository.findByUser(existingUser);
        return feedbacks.stream()
                .map(FeedbackResponse::fromFeedback)
                .collect(Collectors.toList());
    }

    @Override
    public List<FeedbackResponse> getFeedbacksByProduct(Integer productId) throws DataNotFoundException {
        Product existingProduct = productRepository.findById(productId)
                .orElseThrow(() -> new DataNotFoundException("Product not found"));

        List<Feedback> feedbacks = feedbackRepository.findByProduct(existingProduct);
        return feedbacks.stream()
                .map(FeedbackResponse::fromFeedback)
                .collect(Collectors.toList());
    }

    @Override
    public List<FeedbackResponse> getFeedbacksByUserAndProduct(Integer userId, Integer productId) throws DataNotFoundException {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new DataNotFoundException("User not found"));

        Product existingProduct = productRepository.findById(productId)
                .orElseThrow(() -> new DataNotFoundException("Product not found"));

        List<Feedback> feedbacks = feedbackRepository.findByUserAndProduct(existingUser, existingProduct);
        return feedbacks.stream()
                .map(FeedbackResponse::fromFeedback)
                .collect(Collectors.toList());
    }
}
