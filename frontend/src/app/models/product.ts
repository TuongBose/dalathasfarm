import { Category } from "./category";
import { ProductImage } from "./product.image";

export interface Product {
    id:number;
    name: string;
    price: number;
    description: string;
    stock_quantity: number;
    category: Category;
    thumbnail:string;
    thumbnailUrl:string;
    productImages: ProductImage[];
}