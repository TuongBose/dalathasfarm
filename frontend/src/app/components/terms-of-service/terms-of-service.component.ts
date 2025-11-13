import { Component,OnInit } from "@angular/core";
import { CommonModule } from "@angular/common";
import { PolicyService } from "../../services/policy.service";
import { HeaderComponent } from "../header/header.component";

@Component({
  selector: 'app-terms-of-service',
  standalone: true,
  template: `
  <app-header></app-header>
    <div class="container mx-auto p-6 bg-white shadow-lg rounded-lg max-w-4xl mt-10">
      <div class="prose" [innerHTML]="content"></div>
    </div>
  `,
  imports: [
    CommonModule,
    HeaderComponent
]
})

export class TermsOfServiceComponent implements OnInit{
  content: string = '';

  constructor(private policyService: PolicyService) {}

  ngOnInit(): void {
    this.policyService.getTermsOfService().subscribe({
      next: (data) => this.content = data,
      error: (err) => console.error('Error loading terms of service', err)
    });
  }
}