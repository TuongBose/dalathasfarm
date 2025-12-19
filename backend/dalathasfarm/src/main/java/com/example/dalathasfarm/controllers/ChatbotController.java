package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.services.Chatbot.IChatbotService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("${api.prefix}/chatbot")
public class ChatbotController {
    private final IChatbotService chatbotService;

    @PostMapping
    public ResponseEntity<String> chat(@RequestBody Map<String, String> req) {
        return ResponseEntity.ok(chatbotService.chat(req.get("message")));
    }
}
