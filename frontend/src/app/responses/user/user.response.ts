import { Role } from "../../models/role";

export interface UserResponse {
    id: number;
    dateOfBirth: Date;
    roleName: boolean;
    address: string;
    phoneNumber: string;
    isActive: boolean;
    fullName: string;
    email: string;
    role:Role;
}