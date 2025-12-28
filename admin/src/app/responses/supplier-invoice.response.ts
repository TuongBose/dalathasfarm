import { Supplier } from "../models/supplier";
import { SupplierInvoiceDetailResponse } from "./supplier-invoice-detail.response";

export interface SupplierInvoiceResponse{
    id: number;
    supplier: Supplier;
    invoiceNumber: string;
    invoiceDate: Date;
    totalMoney:number;
    taxAmount:number;
    paymentMethod:string;
    paymentStatus:string;
    note:string;
    invoiceFile: string;
    isUsed:boolean;
    supplierInvoiceDetailResponses:SupplierInvoiceDetailResponse[];
}