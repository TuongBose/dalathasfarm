import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpParams } from "@angular/common/http";
import { Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";
import { SupplierOrderDto } from "../dtos/supplier-order.dto";

@Injectable({
    providedIn: 'root'
})

export class SupplierOrderService {
    private apiGetAllSupplierOrder = `${environment.apiBaseUrl}/supplier-orders`;

    constructor(private http: HttpClient) { }

    getAllSupplierOrder(): Observable<ApiResponse> {
        return this.http.get<ApiResponse>(this.apiGetAllSupplierOrder);
    }

    createSupplierOrder(supplierOrderDto: SupplierOrderDto): Observable<ApiResponse> {
        return this.http.post<ApiResponse>(this.apiGetAllSupplierOrder, supplierOrderDto);
    }

    viewFile(fileName: string) {
        return `${this.apiGetAllSupplierOrder}/files/${fileName}`;
    }

    updateStatusSupplierOrder(supplierOrderId:number, status:string):Observable<ApiResponse>{
        return this.http.put<ApiResponse>(`${this.apiGetAllSupplierOrder}/status/${supplierOrderId}/${status}`,null);
    }
}