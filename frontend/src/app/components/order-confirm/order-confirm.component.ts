import { Component, OnInit } from '@angular/core';
import { HeaderComponent } from '../header/header.component';
import { FooterComponent } from '../footer/footer.component';
import { CommonModule } from '@angular/common';
import { OrderResponse } from '../../responses/order.response';
import { OrderService } from '../../services/order.service';
import { OrderDetail } from '../../models/order.detail';

@Component({
  selector: 'app-order-confirm',
  standalone: true,
  templateUrl: './order-confirm.component.html',
  styleUrl: './order-confirm.component.scss',
  imports:[
    HeaderComponent,
    FooterComponent,
    CommonModule
  ]
})
export class OrderConfirmComponent implements OnInit {
  orderResponse: OrderResponse = {
    id: 0,
    address: '',
    userId: 1,
    note: '',
    email: '',
    totalPrice: 0,
    phoneNumber: '',
    orderDate: new Date(),
    fullName: '',
    status: '',
    paymentMethod: '',
    orderDetails: [],
    shippingDate:new Date(),
  }

  constructor(private orderService: OrderService) { }

  ngOnInit(): void {
    this.getOrderDetails()
  }

  getOrderDetails(): void {
    debugger
    const orderId = 8;
    this.orderService.getOrderById(orderId).subscribe({
      next: (response: any) => {
        debugger
        this.orderResponse.id = response.id;
        this.orderResponse.userId = response.userId;
        this.orderResponse.fullName = response.fullName;
        this.orderResponse.email = response.email;
        this.orderResponse.phoneNumber = response.phoneNumber;
        this.orderResponse.address = response.address;
        this.orderResponse.note = response.note;
        this.orderResponse.orderDate = response.orderDate;
        this.orderResponse.paymentMethod = response.paymentMethod;
        this.orderResponse.status = response.status;
        this.orderResponse.totalPrice = response.totalPrice;
        this.orderResponse.shippingDate = response.shippingDate;
        debugger
        this.orderResponse.orderDetails=response.orderDetails.map((orderDetail:OrderDetail)=>{
          //orderDetail.product.thumnail = `${environment.apiBaseUrl}/products/images/${orderDetail}` su ly lay thumbnail
          return orderDetail;
        });
        
      },
      complete: () => { debugger },
      error: (error: any) => {
        debugger
        console.error('Error fetching detail: ', error);
      }
    })
  }
}
