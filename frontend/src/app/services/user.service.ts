import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../environments/environment';
import { ApiResponse } from '../responses/api.response';
import { UserResponse } from '../responses/user/user.response';
import { RegisterDto } from '../dtos/user/register.dto';
import { LoginDto } from '../dtos/user/login.dto';
import { UpdateUserDto } from '../dtos/user/update.user.dto';
import { ChangePasswordDto } from '../dtos/user/change-password.dto';
import { TokenService } from './token.service';

@Injectable({
  providedIn: 'root'
})

export class UserService {
  private apiRegister = `${environment.apiBaseUrl}/users/register`;
  private apiLogin = `${environment.apiBaseUrl}/users/login`;
  private apiUserDetails = `${environment.apiBaseUrl}/users/details`;

  private apiConfig = {
    headers: this.createHeads(),
  }
  constructor(private http: HttpClient, private tokenService: TokenService) { }

  private createHeads(): HttpHeaders {
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Accept-Language': 'vi'
    })
  }

  register(registerDto: RegisterDto): Observable<ApiResponse> {
    debugger
    return this.http.post<ApiResponse>(this.apiRegister, registerDto, this.apiConfig);
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

  changePassword(changePasswordDto: ChangePasswordDto,): Observable<ApiResponse> {
    const userId = this.tokenService.getUserId();
    return this.http.put<ApiResponse>(
      `${environment.apiBaseUrl}/users/change-password/${userId}`,
      changePasswordDto
    );
  }
}
