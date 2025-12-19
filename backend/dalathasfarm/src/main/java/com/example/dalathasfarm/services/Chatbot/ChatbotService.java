package com.example.dalathasfarm.services.Chatbot;

import com.example.dalathasfarm.models.ChatbotKnowledge;
import com.example.dalathasfarm.repositories.ChatbotKnowledgeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static java.util.stream.Collectors.joining;

@Service
@RequiredArgsConstructor
public class ChatbotService implements IChatbotService {
    private final WebClient webClient;
    private final ChatbotKnowledgeRepository chatbotKnowledgeRepository;

    @Value("${ollama.model}")
    private String model;

    @Override
    public String chat(String message) {

        // 1. Retrieve knowledge
        List<ChatbotKnowledge> docs = chatbotKnowledgeRepository.search(message);

        // 2. Build context
        String context = docs.stream()
                .map(d -> "- " + d.getContent())
                .collect(Collectors.joining("\n"));

        // 3. Build prompt
        String prompt = """
        Bạn là trợ lý AI của cửa hàng Dalat Hasfarm.

        THÔNG TIN CỬA HÀNG (CHỈ DÙNG THÔNG TIN SAU):
        %s

        CÂU HỎI KHÁCH HÀNG:
        %s

        QUY TẮC:
        - Chỉ trả lời dựa trên thông tin được cung cấp
        - Nếu không có thông tin, hãy nói "Shop hiện chưa có thông tin này"
        """.formatted(context, message);

        // 4. Call Ollama
        return webClient.post()
                .uri("/api/generate")
                .bodyValue(Map.of(
                        "model", "qwen2.5:7b",
                        "prompt", prompt,
                        "stream", false
                ))
                .retrieve()
                .bodyToMono(String.class)
                .block();
    }
}
