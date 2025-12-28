import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpParams } from "@angular/common/http";
import { Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";

@Injectable({
    providedIn: 'root'
})

export class CouponService {
    private apiBaseUrl = environment.apiBaseUrl;

    constructor(private http: HttpClient) { }

    getAllCoupon(): Observable<ApiResponse> {
        return this.http.get<ApiResponse>(`${this.apiBaseUrl}/coupons`)
    }

    updateStatusCoupon(id:number): Observable<ApiResponse> {
        return this.http.put<ApiResponse>(`${this.apiBaseUrl}/coupons/${id}`,null)
    }
}