import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpParams } from "@angular/common/http";
import { Observable } from "rxjs";
import { ApiResponse } from "../responses/api.response";
import { ProductDto } from "../dtos/product.dto";

@Injectable({
    providedIn: 'root'
})

export class ProductService {
    private apiGetAllProduct = `${environment.apiBaseUrl}/products`;
    constructor(private http: HttpClient) { }

    getAllProduct(keyword: string, selectedCategoryId: number, page: number, limit: number): Observable<ApiResponse> {
        const params = new HttpParams()
            .set('keyword', keyword.toString())
            .set('categoryId', selectedCategoryId.toString())
            .set('page', page.toString())
            .set('limit', limit.toString());

        return this.http.get<ApiResponse>(this.apiGetAllProduct, { params });
    }

    getProductById(productId: number) :Observable<ApiResponse>{
        return this.http.get<ApiResponse>(`${environment.apiBaseUrl}/products/${productId}`);
    }

    getProductByProductIds(productIds: number[]): Observable<ApiResponse> {
        // Chuyển danh sách MASANPHAM thành một chuỗi và truyền vào params
        debugger
        const params = new HttpParams().set('ids', productIds.join(','));
        return this.http.get<ApiResponse>(`${this.apiGetAllProduct}/by-ids`,{params});
    }

    deleteProduct(productId: number): Observable<string>{
        debugger
        return this.http.delete<string>( `${this.apiGetAllProduct}/${productId}`)
    }

    insertProduct(productDto: ProductDto):Observable<any>{
        return this.http.post(`${this.apiGetAllProduct}`,productDto);
    }

    // uploadImages(masanpham: number, files:File[]):Observable<any>{
    //     const formData=new FormData();
    //     for(let i = 0;i<files.length;i++    )
    // }
}