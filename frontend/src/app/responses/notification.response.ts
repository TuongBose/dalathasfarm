export interface NotificationResponse {
    notification_id: number;
    user_id: number;
    title: string;
    content: string;
    type: string;
    is_read: boolean;
    showMenu?: boolean;
    createdAt :Date;
    updatedAt :Date;
}