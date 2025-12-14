import { OrderDetailResponse } from "./order.detail.response";

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
    orderDetailResponses: OrderDetailResponse[],
}