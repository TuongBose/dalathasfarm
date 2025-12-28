import { Supplier } from "../models/supplier";
import { OrderDetailResponse } from "./order.detail.response";
import { SupplierOrderDetailResponse } from "./supplier-order-detail.response";
import { UserResponse } from "./user/user.response";

export interface SupplierOrderResponse{
    id: number;
    supplier: Supplier;
    userResponse: UserResponse;
    orderDate: Date;
    status: string;
    totalMoney:number;
    note:string;
    orderFile:string;
    supplierOrderDetailResponses:SupplierOrderDetailResponse[];
}