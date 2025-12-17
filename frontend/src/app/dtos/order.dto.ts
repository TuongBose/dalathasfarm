import { CartItemDto } from "./cartitem.dto";

export class OrderDto{
    userId: number;
    fullName:string;
    email:string;
    phoneNumber:string;
    address:string;
    note:string;
    totalPrice:number;
    paymentMethod:string;
    shippingMethod:string;
    shippingDate:Date;
    status:string;
    platform:string;
    vnpTxnRef?:string;
    couponCode?:string;
    cartItems: CartItemDto[];

  constructor(data:any){
    this.userId=data.userId;
    this.fullName=data.fullName;
    this.email=data.email;
    this.phoneNumber=data.phoneNumber;
    this.address=data.address;
    this.note=data.note;
    this.totalPrice=data.totalPrice;
    this.paymentMethod=data.paymentMethod;
    this.shippingMethod=data.shippingMethod;
    this.shippingDate=data.shippingDate;
    this.status=data.status;
    this.platform=data.platform;
    this.vnpTxnRef = data.vnpTxnRef;
    this.couponCode=data.couponCode;
    this.cartItems=data.cartItems
  }
}