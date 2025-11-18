import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpParams } from "@angular/common/http";
import { Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";

@Injectable({
    providedIn: 'root'
})

export class CategoryService {
    private apiGetAllCategory = `${environment.apiBaseUrl}/categories`;
    constructor(private http: HttpClient) { }

    getAllCategory(page: number, limit: number): Observable<ApiResponse> {
        const params = new HttpParams()
            .set('page', page.toString())
            .set('limit', limit.toString());

        return this.http.get<ApiResponse>(this.apiGetAllCategory, { params });
    }

    getCategoryById(categoryId:number):Observable<ApiResponse>{
        return this.http.get<ApiResponse>(`${this.apiGetAllCategory}/${categoryId}`)
    }
}