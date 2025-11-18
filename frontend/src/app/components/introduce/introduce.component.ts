import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { HeaderComponent } from '../header/header.component';
import { FooterComponent } from '../footer/footer.component';
import { environment } from '../../environments/environment';
import { BaseComponent } from '../base/base.component';

@Component({
  selector: 'app-introduce',
  standalone: true,
  templateUrl: './introduce.component.html',
  styleUrl: './introduce.component.scss',
  imports: [
    HeaderComponent,
    FooterComponent,
  ]

})
export class IntroduceComponent extends BaseComponent implements OnInit {
  @ViewChild('contactForm') contactForm?: ElementRef<HTMLFormElement>;

  introduceName1: string = 'snowy_orchid.jpg';
  introduceName2: string = 'phunu.jpg';
  introduceName3: string = 'thuongbinh.jpg';
  introduceUrl1?: string;
  introduceUrl2?: string;
  introduceUrl3?: string;

  ngOnInit(): void {
    this.introduceUrl1 = `${environment.apiBaseUrl}/products/images/${this.introduceName1}`;
    this.introduceUrl2 = `${environment.apiBaseUrl}/products/images/${this.introduceName2}`;
    this.introduceUrl3 = `${environment.apiBaseUrl}/products/images/${this.introduceName3}`;
  }

  sendMessage(): void {
    this.toastService.showToast({
      defaultMsg: 'Cảm ơn bạn đã gửi lời nhắn cho chúng tôi',
      title: 'Thông báo',
      delay: 3000,
      type: 'success'
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });

    if (this.contactForm?.nativeElement) {
      this.contactForm.nativeElement.reset();
    }
  }
}
