import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ApiResponse } from '../responses/api.response';
import { UserResponse } from '../responses/user/user.response';
import { environment } from '../environments/environment';
import { LoginDto } from '../dtos/user/login.dto';
import { UpdateUserDto } from '../dtos/user/update.user.dto';

@Injectable({
  providedIn: 'root'
})

export class UserService {
  private apiUser = `${environment.apiBaseUrl}/users`;
  private apiLogin = `${environment.apiBaseUrl}/users/login`;
  private apiUserDetails = `${environment.apiBaseUrl}/users/details`;

  private apiConfig = {
    headers: this.createHeads(),
  }
  constructor(private http: HttpClient,) { }

  private createHeads(): HttpHeaders {
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Accept-Language': 'vi'
    })
  }

  login(loginDto: LoginDto): Observable<ApiResponse> {
    debugger
    return this.http.post<ApiResponse>(this.apiLogin, loginDto, this.apiConfig);
  }

  getUserDetails(token: string): Observable<ApiResponse> {
    debugger
    return this.http.post<ApiResponse>(this.apiUserDetails, {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`
      })
    });
  }

  saveUserToLocalStorage(userResponse?: UserResponse, rememberMe: boolean = false) {
    try {
      debugger
      if (userResponse == null || !userResponse) { return; }
      // Convert the accountResponse object to a JSON string
      const userResponseJSON = JSON.stringify(userResponse);

      // Save the JSON string to local storage with a key (e.g.,"accountResponse")
      if (rememberMe) {
        localStorage.setItem('user', userResponseJSON);
      }
      else {
        sessionStorage.setItem('user', userResponseJSON)
      }
      console.log('User response saved to storage.');
    } catch (error) {
      console.error('Error saving user response to storage: ', error);
    }
  }

  getUserFromLocalStorage(): UserResponse | null {
    debugger
    try {
      // Retrieve the JSON string from local storage using the key
      const userResponseJSON = localStorage.getItem('user') || sessionStorage.getItem('user');
      if (userResponseJSON == null || userResponseJSON == undefined) { return null; }

      // Parse the JSON string back to an object
      const userResponse = JSON.parse(userResponseJSON!);
      console.log('User retrieved from storage.');
      return userResponse;
    } catch (error) {
      console.error('Error retrieving user from storage: ', error);
      return null;
    }
  }

  removeUserFromLocalStorage(): void {
    debugger
    try {
      localStorage.removeItem('user');
      sessionStorage.removeItem('user');
      console.log('User data removed from storage.');
    } catch (error) {
      console.error('Error revoming account from storage: ', error)
    }
  }

  updateUserDetail(token: string, updateUserDto: UpdateUserDto): Observable<ApiResponse> {
    let userResponse = this.getUserFromLocalStorage();
    return this.http.put<ApiResponse>(`${this.apiUserDetails}/${userResponse?.id}`, updateUserDto, {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`
      })
    })
  }

  getAllUserAdmin(page: number, limit: number): Observable<ApiResponse> {
    const params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString());

    return this.http.get<ApiResponse>(`${this.apiUser}/admins`, { params });
  }

  getAllUserEmployee(page: number, limit: number): Observable<ApiResponse> {
    const params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString());

    return this.http.get<ApiResponse>(`${this.apiUser}/employees`, { params });
  }

  getAllUserCustomer(page: number, limit: number): Observable<ApiResponse> {
    const params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString());

    return this.http.get<ApiResponse>(`${this.apiUser}/customers`, { params });
  }
}
