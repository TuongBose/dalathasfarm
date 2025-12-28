// src/app/services/statistic.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse, HttpHeaders } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, retry, timeout } from 'rxjs/operators';
import { environment } from '../environments/environment';
import { ApiResponse } from '../responses/api.response';

@Injectable({
  providedIn: 'root',
})
export class DashboardService {
  private apiUrl = `${environment.apiBaseUrl}/dashboard`; 

  constructor(private http: HttpClient) {}

  getDashboard(): Observable<ApiResponse> {
    return this.http.get<ApiResponse>(this.apiUrl);
  }
}