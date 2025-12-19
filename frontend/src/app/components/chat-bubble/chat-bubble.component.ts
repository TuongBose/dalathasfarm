import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-chat-bubble',
  standalone: true,
  imports: [CommonModule],
  template: `
    <button class="chat-bubble-btn" (click)="openChat()">
      <i class="fas fa-comment-dots"></i>
      <span class="pulse-ring"></span>
    </button>
  `,
  styles: [`
    :host {
      position: fixed;
      bottom: 30px;
      right: 30px;
      z-index: 9999;
    }

    .chat-bubble-btn {
      width: 60px;
      height: 60px;
      background: linear-gradient(135deg, #667eea, #764ba2);
      border: none;
      border-radius: 50%;
      color: white;
      font-size: 28px;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
      cursor: pointer;
      transition: all 0.3s ease;
      position: relative;
      animation: float 3s ease-in-out infinite;
    }

    .chat-bubble-btn:hover {
      transform: scale(1.1);
      box-shadow: 0 12px 35px rgba(102, 126, 234, 0.6);
    }

    .pulse-ring {
      position: absolute;
      width: 100%;
      height: 100%;
      background: transparent;
      border: 4px solid #667eea;
      border-radius: 50%;
      opacity: 0.6;
      animation: pulse 2s infinite;
    }

    @keyframes pulse {
      0% {
        transform: scale(0.8);
        opacity: 0.6;
      }
      70% {
        transform: scale(1.3);
        opacity: 0;
      }
      100% {
        transform: scale(1.3);
        opacity: 0;
      }
    }

    @keyframes float {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(-10px); }
    }
  `]
})
export class ChatBubbleComponent {
  constructor(private router: Router) {}

  openChat(): void {
    this.router.navigate(['/chatbot']);
  }
}