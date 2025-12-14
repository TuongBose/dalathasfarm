import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";

@Injectable({
    providedIn: 'root'
})

export class OrderDetailService {
    private apiOrderDetail = `${environment.apiBaseUrl}/order-details`;
    constructor(private http: HttpClient) { }

    getOrderDetailsByOrderId(orderId: number): Observable<ApiResponse> {
        return this.http.get<ApiResponse>(`${this.apiOrderDetail}/order/${orderId}`);
    }
}