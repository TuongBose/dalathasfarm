import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { ApiResponse } from "../responses/api.response";
import { Observable } from "rxjs";
import { environment } from "../environments/environment";

@Injectable({
    providedIn:'root'
})

export class PaymentService{
    private apiPayment = `${environment.apiBaseUrl}/payments`;

  constructor(private http: HttpClient) { }
  createPaymentUrl(payload: { amount: number,language: string}): Observable<ApiResponse> {
    return this.http.post<ApiResponse>(`${this.apiPayment}/create-payment-url`, payload);
  }
}