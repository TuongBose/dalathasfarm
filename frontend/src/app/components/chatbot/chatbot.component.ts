import { Component, OnInit } from '@angular/core';
import { HeaderComponent } from '../header/header.component';
import { FooterComponent } from '../footer/footer.component';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Product } from '../../models/product';
import { Category } from '../../models/category';
import { environment } from '../../environments/environment';
import { ChatbotService } from '../../services/chatbot.service';

interface Message {
  role: 'user' | 'bot';
  text: string;
  timestamp: Date;
}

@Component({
  selector: 'app-chatbot',
  standalone: true,
  templateUrl: './chatbot.component.html',
  styleUrl: './chatbot.component.scss',
  imports: [
    HeaderComponent,
    CommonModule,
    FormsModule,
  ]

})
export class ChatbotComponent implements OnInit {
  messages: Message[] = [];
  userInput: string = '';
  isLoading: boolean = false;
  isMinimized: boolean = true;

  constructor(private chatbotService: ChatbotService) { }

  ngOnInit(): void {
    this.messages.push({
      role: 'bot',
      text: '👋 Xin chào! Tôi là trợ lý bán hàng của Đà Lạt Hasfarm. Bạn cần hỏi gì?',
      timestamp: new Date()
    });
  }

  toggleChat(): void {
    this.isMinimized = !this.isMinimized;
  }

  sendMessage(): void {
    if (!this.userInput.trim()) return;

    // Add user message
    this.messages.push({
      role: 'user',
      text: this.userInput,
      timestamp: new Date()
    });

    this.isLoading = true;
    const question = this.userInput;
    this.userInput = '';

    // Call backend
    this.chatbotService.askQuestion(question).subscribe(
      (response: any) => {
        debugger
        this.messages.push({
          role: 'bot',
          text: response.response,
          timestamp: new Date()
        });
        this.isLoading = false;
      },
      (error) => {
        this.messages.push({
          role: 'bot',
          text: 'Xin lỗi, tôi gặp lỗi khi xử lý câu hỏi. Vui lòng thử lại.',
          timestamp: new Date()
        });
        this.isLoading = false;
      }
    );
  }
}
