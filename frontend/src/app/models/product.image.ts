import { Product } from "./product";

export interface ProductImage {
    id: number;
    product: Product;
    name: string;
    imageUrl:string;
}