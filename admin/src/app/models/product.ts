import { SafeHtml } from "@angular/platform-browser";
import { ProductImage } from "./product.image";

export interface Product {
    id:number;
    name: string;
    price: number;
    description: string;
    components: string;
    safeComponents?: SafeHtml;
    stockQuantity: number;
    categoryId: number;
    thumbnail:string;
    thumbnailUrl:string;
    productImages: ProductImage[];
}