import { HttpClient } from "@angular/common/http";
import { environment } from "../environments/environment";
import { BehaviorSubject, Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";
import { NotificationResponse } from "../responses/notification.response";
import { Injectable } from "@angular/core";

@Injectable({
    providedIn: 'root'
})
export class NotificationService {
    private readonly apiGetNotifications = `${environment.apiBaseUrl}/notifications`;
    private readonly apiMarkAsRead = `${environment.apiBaseUrl}/notifications/mark-as-read`;
    private readonly apiGetUnreadNotifications = `${environment.apiBaseUrl}/notifications/unread`;
    private readonly apiDeleteNotification = `${environment.apiBaseUrl}/notifications/delete`;
    private readonly apiMarkAllAsRead = `${environment.apiBaseUrl}/notifications/mark-all-as-read`;

    constructor(private http: HttpClient) { }

    private unreadCountSubject = new BehaviorSubject<number>(0);
    unreadCount$ = this.unreadCountSubject.asObservable();

    //Api lấy danh sách thông báo theo userId
    getNotificationByUserId(): Observable<ApiResponse> {
        debugger
        return this.http.get<ApiResponse>(`${this.apiGetNotifications}`);
    }
    //Api đánh dấu thông báo đã đọc
    markAsRead(notificationId: number): Observable<ApiResponse> {
        debugger
        return this.http.patch<ApiResponse>(`${this.apiMarkAsRead}/${notificationId}`, {});
    }
    //Api lấy danh sách thông báo chưa đọc theo userId
    getUnreadNotifications(): Observable<ApiResponse> {
        debugger
        return this.http.get<ApiResponse>(`${this.apiGetUnreadNotifications}`);
    }
    //Api xóa thông báo
    deleteNotificationById(notificationId: number): Observable<ApiResponse> {
        debugger
        return this.http.delete<ApiResponse>(`${this.apiDeleteNotification}/${notificationId}`)
    }

    markAllAsRead(): Observable<ApiResponse> {
        return this.http.post<ApiResponse>(`${this.apiMarkAllAsRead}`, {});
    }

    updateUnreadCount(count: number): void {
        this.unreadCountSubject.next(count);
    }

    getUnreadCount(): number {
        return this.unreadCountSubject.value;
    }
}