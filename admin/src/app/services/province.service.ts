import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable } from "rxjs";
import { Province } from "../responses/province.response";

@Injectable({
    providedIn: 'root'
})

export class ProvinceService {
    private readonly LOCAL_DATA = 'assets/openapi.json';
    
    constructor(private http: HttpClient) { }

    getProvinces(): Observable<Province[]> {
        return this.http.get<Province[]>(this.LOCAL_DATA);
    }
}