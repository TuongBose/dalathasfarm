export class CartItemDto{
    productId:number;
    quantity:number;

  constructor(data:any){
    this.productId=data.productId;
    this.quantity=data.quantity
  }
}