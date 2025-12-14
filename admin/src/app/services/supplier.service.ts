import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpParams } from "@angular/common/http";
import { Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";

@Injectable({
    providedIn: 'root'
})

export class SupplierService {
    private apiGetAllSupplier = `${environment.apiBaseUrl}/suppliers`;
    constructor(private http: HttpClient) { }

    getAllSupplier(): Observable<ApiResponse> {

        return this.http.get<ApiResponse>(this.apiGetAllSupplier);
    }

    getSupplierById(supplierId:number):Observable<ApiResponse>{
        return this.http.get<ApiResponse>(`${this.apiGetAllSupplier}/${supplierId}`)
    }
}