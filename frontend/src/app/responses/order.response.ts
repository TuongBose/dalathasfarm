import { OrderDetail } from "../models/order.detail";

export interface OrderResponse{
    id: number,
    address: string,
    userId: number,
    note: string,
    email: string,
    totalPrice: number,
    phoneNumber: string,
    orderDate: Date,
    fullName: string,
    status: string,
    paymentMethod: string,
    shippingDate:Date,
    orderDetails: OrderDetail[],
}