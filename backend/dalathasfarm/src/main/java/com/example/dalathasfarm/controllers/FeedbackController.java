package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.dtos.FeedbackDto;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.responses.feedback.FeedbackResponse;
import com.example.dalathasfarm.services.Feedback.IFeedbackService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Objects;

@RestController
@RequestMapping("${api.prefix}/feedbacks")
@RequiredArgsConstructor
public class FeedbackController {
    private final IFeedbackService feedbackService;

    @GetMapping("")
    public ResponseEntity<ResponseObject> getAllFeedbacks(
            @RequestParam(value = "user_id", required = false) Integer userId,
            @RequestParam(value = "product_id") Integer productId
    ) throws Exception {
        List<FeedbackResponse> feedbackResponses;
        if (userId == null) {
            feedbackResponses = feedbackService.getFeedbacksByProduct(productId);
        } else {
            feedbackResponses = feedbackService.getFeedbacksByUserAndProduct(userId, productId);
        }

        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get all feedbacks successfully")
                .status(HttpStatus.OK)
                .data(feedbackResponses)
                .build());
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
    public ResponseEntity<ResponseObject> updateFeedback(
            @PathVariable Integer id,
            @RequestBody FeedbackDto feedbackDto
    ) throws Exception {
        User loginUser = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (!Objects.equals(loginUser.getId(), feedbackDto.getUserId())) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message("You can not update feedback as another user")
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        }

        feedbackService.updateFeedback(feedbackDto, id);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Update feedback successfully")
                .status(HttpStatus.OK)
                .data(null)
                .build());

    }

    @PostMapping("")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
    public ResponseEntity<ResponseObject> insertFeedback(
            @Valid @RequestBody FeedbackDto feedbackDto
    ) throws Exception {
        User loginUser = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (loginUser.getId() != feedbackDto.getUserId()) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message("You can not feedback as another user")
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        }
        feedbackService.insertFeedback(feedbackDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Insert feedback successfully")
                .status(HttpStatus.OK)
                .data(null)
                .build());
    }

//    @PostMapping("/generateFakeFeedbacks")
//    @PreAuthorize("hasRole('ROLE_ADMIN')")
//    public ResponseEntity<ResponseObject> generateFakeFeedbacks() throws Exception {
//        feedbackService.generateFakeFeedbacks();
//        return ResponseEntity.ok(ResponseObject.builder()
//                .message("Insert fake feedbacks successfully")
//                .data(null)
//                .status(HttpStatus.OK)
//                .build());
//    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> deleteFeedback(@PathVariable int id) throws Exception {
        feedbackService.deleteFeedback(id);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Delete feedback successfully")
                .status(HttpStatus.OK)
                .data(null)
                .build());
    }
}
