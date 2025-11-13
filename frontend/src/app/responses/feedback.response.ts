import { UserResponse } from "./user/user.response";

export interface FeedbackResponse {
  id: number;
  userResponse: UserResponse;
  content: string;
  star: number;
  productId: number;
  createdAt: Date;
}