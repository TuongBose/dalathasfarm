export interface Order {
    id:number;
    userId: number;
    fullName: string;
    email: string;
    phoneNumber: string;
    address: string;
    note: string;
    totalPrice: number;
    paymentMethod: string;
}