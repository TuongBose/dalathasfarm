import { Component, OnInit } from '@angular/core';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap'
import { environment } from '../../environments/environment';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-footer',
  standalone: true,
  templateUrl: './footer.component.html',
  styleUrl: './footer.component.css',
  imports: [
    FormsModule,
    RouterModule
  ]
})
export class FooterComponent {
  email: string = '';

  onSubmit() {
    if (this.email) {
      console.log('Subscribed:', this.email);
      alert('Cảm ơn bạn đã đăng ký nhận tin!');
      this.email = '';
    }
  }
}
