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
    status:string;
    vnp_TxnRef?:string;
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
    this.status=data.status;
    this.vnp_TxnRef = data.vnp_TxnRef;
    this.cartItems=data.cartItems
  }
}