import { Product } from "../models/product";

export interface OrderDetailResponse {
    orderId: number;
    productResponse: Product;
    price: number;
    quantity: number;
    totalMoney: number;
}