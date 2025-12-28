import { Product } from "../models/product";

export interface PurchaseOrderDetailResponse {
    purchaseOrderId: number;
    productResponse: Product;
    quantity: number;
}