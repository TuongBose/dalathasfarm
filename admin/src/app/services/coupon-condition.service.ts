import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpParams } from "@angular/common/http";
import { Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";

@Injectable({
    providedIn: 'root'
})

export class CouponConditionService {
    private apiBaseUrl = environment.apiBaseUrl;

    constructor(private http: HttpClient) { }

    getCouponConditionByCouponId(id:number): Observable<ApiResponse> {
        return this.http.get<ApiResponse>(`${this.apiBaseUrl}/coupon-conditions/${id}`)
    }
}