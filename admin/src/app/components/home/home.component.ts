import { Component, NgModule, OnInit } from '@angular/core';
import { Router, RouterModule } from '@angular/router';
import { UserService } from '../../services/user.service';
import { NgModel } from '@angular/forms';
import { BaseComponent } from '../base/base.component';
import { UserResponse } from '../../responses/user/user.response';

@Component({
  selector: 'app-home',
  standalone: true,
  templateUrl: './home.component.html',
  styleUrl: './home.component.css',
  imports: [
    RouterModule
  ]
})
export class HomeComponent extends BaseComponent implements OnInit {
  user?: number | null;

  ngOnInit(): void {
    debugger
    this.user = this.userService.getUserFromLocalStorage()?.id;
    if (!this.user)
      this.router.navigate(['/login']);
  }

  logout(): void {
    this.userService.removeUserFromLocalStorage();
    this.tokenService.removeToken();
    this.user = null;

    setTimeout(() => {
      this.router.navigate(['/login']);
    }, 2000);
  }
}
