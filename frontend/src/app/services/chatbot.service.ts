import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpParams } from "@angular/common/http";
import { Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";

@Injectable({
    providedIn: 'root'
})

export class ChatbotService {
    private apiUrl = `${environment.apiBaseUrl}/chatbot`;
    constructor(private http: HttpClient) { }

    askQuestion(message: string): Observable<any> {
    return this.http.post(`${this.apiUrl}`, { message });
  }
}