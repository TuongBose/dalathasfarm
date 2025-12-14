import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { environment } from "../environments/environment";

@Injectable({
  providedIn: 'root'
})
export class PolicyService {
  private apiUrl = `${environment.apiBaseUrl}/policies`;

  constructor(private http: HttpClient) {}

  getPrivacyPolicy(): Observable<string> {
    return this.http.get(`${this.apiUrl}/privacy-policy`, { responseType: 'text' });
  }

  getTermsOfService(): Observable<string> {
    return this.http.get(`${this.apiUrl}/terms-of-service`, { responseType: 'text' });
  }
}