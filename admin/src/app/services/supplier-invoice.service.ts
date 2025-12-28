import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpParams } from "@angular/common/http";
import { Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";
import { SupplierOrderDto } from "../dtos/supplier-order.dto";

@Injectable({
    providedIn: 'root'
})

export class SupplierInvoiceService {
    private apiGetAllSupplierInvoice = `${environment.apiBaseUrl}/supplier-invoices`;

    constructor(private http: HttpClient) { }

    getAllSupplierInvoice(): Observable<ApiResponse> {
        return this.http.get<ApiResponse>(this.apiGetAllSupplierInvoice);
    }

    viewFile(fileName: string) {
        return `${this.apiGetAllSupplierInvoice}/files/${fileName}`;
    }

    blockOrEnable(supplierInvoiceId:number, isUsed:number):Observable<ApiResponse>{
        return this.http.put<ApiResponse>(`${this.apiGetAllSupplierInvoice}/block/${supplierInvoiceId}/${isUsed}`,null);
    }
}