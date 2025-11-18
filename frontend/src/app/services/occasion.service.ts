import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpParams } from "@angular/common/http";
import { ApiResponse } from "../responses/api.response";
import { Observable } from "rxjs";

@Injectable({
    providedIn: 'root'
})

export class OccasionService {
    private apiGetAllCategory = `${environment.apiBaseUrl}/occasions`;
    constructor(private http: HttpClient) { }

    getAllOccasion(page: number, limit: number): Observable<ApiResponse> {
        const params = new HttpParams()
            .set('page', page.toString())
            .set('limit', limit.toString());

        return this.http.get<ApiResponse>(this.apiGetAllCategory, { params });
    }

    getTodayOccasions ():Observable<ApiResponse>{
        return this.http.get<ApiResponse>(`${this.apiGetAllCategory}/active/today`)
    }

    getOccasionById(occasionId:number):Observable<ApiResponse>{
return this.http.get<ApiResponse>(`${this.apiGetAllCategory}/${occasionId}`)
     }
}