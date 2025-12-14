export class ProductDto {
  name: string;
  price: number;
  description: string;
  categoryId: number;

  constructor(data: any) {
    this.name = data.name;
    this.price = data.price;
    this.description = data.description;
    this.categoryId = data.categoryId;
  }
}