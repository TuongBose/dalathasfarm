import { Category } from "./category";
import { ProductImage } from "./product.image";

export interface Product {
    id:number;
    name: string;
    price: number;
    description: string;
    components: string;
    stockQuantity: number;
    category: Category;
    thumbnail:string;
    thumbnailUrl:string;
    productImages: ProductImage[];
}