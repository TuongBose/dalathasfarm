export interface NotificationResponse {
    id: number;
    userId: number;
    title: string;
    content: string;
    type: string;
    isRead: boolean;
    showMenu?: boolean;
    createdAt :Date;
}