// src/app/dtos/feedback.dto.ts
export class FeedbackDto {
  userId: number;
  content: string;
  star: number;
  productId: number;

  constructor(data:any){
    this.userId=data.userId;
    this.content=data.content;
    this.star=data.star;
    this.productId=data.productId;
  }
}