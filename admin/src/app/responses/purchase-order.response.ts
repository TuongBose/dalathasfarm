import { Supplier } from "../models/supplier";
import { PurchaseOrderDetailResponse } from "./purchase-order-detail.response";
import { SupplierInvoiceDetailResponse } from "./supplier-invoice-detail.response";
import { UserResponse } from "./user/user.response";

export interface PurchaseOrderResponse{
    id: number;
    supplierInvoiceId: number;
    userResponse:UserResponse   
    importDate: Date;
    note: string;
    receiptFile:string;
    purchaseOrderDetailResponses:PurchaseOrderDetailResponse[];
}