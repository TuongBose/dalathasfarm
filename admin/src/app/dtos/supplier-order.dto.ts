import { CartItemDto } from "./cartitem.dto";

export class SupplierOrderDto{
    supplierId:number;
    userId:number;
    totalMoney:number;
    note:string;
    cartItems: CartItemDto[];

  constructor(data:any){
    this.supplierId=data.supplierId;
    this.userId=data.userId;
    this.note=data.note;
    this.totalMoney=data.totalMoney;
    this.cartItems=data.cartItems
  }
}