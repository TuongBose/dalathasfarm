import { Product } from "../models/product";

export interface SupplierInvoiceDetailResponse {
    supplierOrderId: number;
    productResponse: Product;
    quantity: number;
    price: number;
    totalMoney: number;
}