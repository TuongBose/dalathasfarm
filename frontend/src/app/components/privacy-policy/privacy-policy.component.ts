import { Component, DOCUMENT, inject, OnInit } from "@angular/core";
import { CommonModule } from "@angular/common";
import { PolicyService } from "../../services/policy.service";
import { HeaderComponent } from "../header/header.component";

@Component({
  selector: 'app-privacy-policy',
  standalone: true,
  template: `
  <app-header></app-header>
    <div class="container">
      <div class="prose" [innerHTML]="content"></div>
    </div>
  `,
  imports: [
    CommonModule,
    HeaderComponent,
  ]
})

export class PrivacyPolicyComponent implements OnInit {
  content: string = '';

  constructor(private policyService: PolicyService) { }

  ngOnInit(): void {
    debugger
    this.policyService.getPrivacyPolicy().subscribe({
      next: (data) => { debugger; this.content = data; },
      error: (err) => console.error('Error loading privacy policy', err)
    });
  }
}