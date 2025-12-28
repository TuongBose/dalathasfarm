import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpParams } from "@angular/common/http";
import { Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";
import { OrderDto } from "../dtos/order.dto";

@Injectable({
    providedIn: 'root'
})

export class OrderService {
    private apiCreateOrder = `${environment.apiBaseUrl}/orders`;
    constructor(private http: HttpClient) { }

    placeOrder(OrderDto: OrderDto): Observable<ApiResponse> {
        return this.http.post<ApiResponse>(this.apiCreateOrder, OrderDto);
    }

    getOrderById(orderId: number): Observable<ApiResponse> {
        return this.http.get<ApiResponse>(`${environment.apiBaseUrl}/orders/${orderId}`);
    }

    updateOrderStatus(vnp_TxnRef: string, status: string): Observable<ApiResponse> {
        debugger
        const params = new HttpParams()
            .set('status', status.toString())
            .set('vnpTxnRef', vnp_TxnRef.toString());
        const url = `${environment.apiBaseUrl}/orders/status`;
        return this.http.put<ApiResponse>(url, null, { params });
    }

    viewFile(fileName: string) {
        return `${this.apiCreateOrder}/files/${fileName}`;
    }

    getOrdersByUserId(userId: number): Observable<ApiResponse> {
        return this.http.get<ApiResponse>(`${this.apiCreateOrder}/user/${userId}`);
    }

    cancelOrder(id: number): Observable<ApiResponse> {
        debugger
        const url = `${this.apiCreateOrder}/cancel/${id}`;
        return this.http.put<ApiResponse>(url, null);
    }
}