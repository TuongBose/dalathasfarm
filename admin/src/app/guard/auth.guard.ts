import { inject, Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, Router, RouterStateSnapshot, CanActivateFn } from '@angular/router';
import { TokenService } from '../services/token.service';
import { UserService } from '../services/user.service';

@Injectable({
    providedIn: 'root'
})
export class AuthGuard {
    constructor(private router: Router, private tokenService: TokenService, private userService:UserService) { }

    canActivate(next: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
        const isTokenExpired = this.tokenService.isTokenExpired();
        const isUserIdValid = this.tokenService.getUserId() > 0;
        const user = this.userService.getUserFromLocalStorage();
        const isAdmin = user?.role.name === 'Admin';

        debugger
        if (!isTokenExpired && isUserIdValid && isAdmin) {
            return true;
        } else {
            alert("Bạn không có quyền truy cập");
            return false;
        }
    }
}

export const AuthGuardFn: CanActivateFn = (next: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean => {
    debugger
    return inject(AuthGuard).canActivate(next, state);
}