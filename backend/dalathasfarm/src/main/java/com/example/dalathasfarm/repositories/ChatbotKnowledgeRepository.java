package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.ChatbotKnowledge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ChatbotKnowledgeRepository extends JpaRepository<ChatbotKnowledge, Long> {
    @Query("""
       SELECT k FROM ChatbotKnowledge k
       WHERE LOWER(k.content) LIKE LOWER(CONCAT('%', :keyword, '%'))
          OR LOWER(k.title) LIKE LOWER(CONCAT('%', :keyword, '%'))
    """)
    List<ChatbotKnowledge> search(@Param("keyword") String keyword);
}
