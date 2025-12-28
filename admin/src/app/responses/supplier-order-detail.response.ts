import { Product } from "../models/product";

export interface SupplierOrderDetailResponse {
    ordersupplierOrderIdId: number;
    productResponse: Product;
    quantity: number;
    price: number;
    totalMoney: number;
}