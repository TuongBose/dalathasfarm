import { OrderDetail } from "../models/order.detail";

export interface OrderResponse{
    id: number,
    address: string,
    userId: number,
    note: string,
    email: string,
    totalMoney: number,
    phoneNumber: string,
    orderDate: Date,
    fullName: string,
    status: string,
    paymentMethod: string,
    shippingMethod:string,
    shippingDate:Date,
    isActive:boolean,
    coupon:string,
    vnpTxnRef:string,
    invoiceFile:string,
    orderDetails: OrderDetail[],
}