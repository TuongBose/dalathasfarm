import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpParams } from "@angular/common/http";
import { Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";
import { SupplierOrderDto } from "../dtos/supplier-order.dto";

@Injectable({
    providedIn: 'root'
})

export class PurchaseOrderService {
    private apiGetAllPurchaseOrder = `${environment.apiBaseUrl}/purchase-orders`;

    constructor(private http: HttpClient) { }

    getAllPurchaseOrder(): Observable<ApiResponse> {
        return this.http.get<ApiResponse>(this.apiGetAllPurchaseOrder);
    }

    viewFile(fileName: string) {
        return `${this.apiGetAllPurchaseOrder}/files/${fileName}`;
    }
}