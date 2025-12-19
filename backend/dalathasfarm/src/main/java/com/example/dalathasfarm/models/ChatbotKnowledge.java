package com.example.dalathasfarm.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chatbot_knowledges")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatbotKnowledge {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    private String content;
    private String type;
}