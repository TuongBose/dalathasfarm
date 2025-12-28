import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Supplier } from '../../models/supplier';
import { SupplierOrderResponse } from '../../responses/supplier-order.response';
import { environment } from '../../environments/environment';
import { Product } from '../../models/product';
import { CartItemDto } from '../../dtos/cartitem.dto';
import { SupplierOrderDto } from '../../dtos/supplier-order.dto';
import { ActivatedRoute } from '@angular/router';
import { SupplierInvoiceResponse } from '../../responses/supplier-invoice.response';
import { PurchaseOrderResponse } from '../../responses/purchase-order.response';

@Component({
  selector: 'app-purchase-order',
  standalone: true,
  templateUrl: './purchase-order.component.html',
  styleUrl: './purchase-order.component.scss',
  imports: [
    CommonModule,
    FormsModule,
  ]

})
export class PurchaseOrderComponent extends BaseComponent implements OnInit {
  purchaseOrders: PurchaseOrderResponse[] = [];
  products: Product[] = [];
  suppliers: Supplier[] = [];
  expandedOrderId: number | null = null;
  selectedSupplierId: number | null = null;
  note: string = '';
  cartItems: CartItemDto[] = [];
  loading = true;
  showCreateModal = false;

  constructor(private route: ActivatedRoute) { super(); }

  ngOnInit(): void {
    this.getAllPurchaseOrder();
  }

  getAllPurchaseOrder() {
    this.purchaseOrderService.getAllPurchaseOrder().subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.purchaseOrders = response.data;
        this.purchaseOrders = this.purchaseOrders.reverse();
      },
      complete: () => { debugger },
      error: (error: HttpErrorResponse) => {
        debugger;
        console.error('Error fetching purchaseOrders: ', error)
      }
    })
  }

  openEditSupplierModal(supplier: Supplier) {
    alert(`Chỉnh sửa sản phẩm: ${supplier.name} (ID: ${supplier.id})`);
  }

  confirmDelete(supplierId: number, supplierName: string) {
    if (confirm(`Bạn có chắc muốn xóa danh mục sản phẩm:\n"${supplierName}" không?`)) {
      this.productService.deleteProduct(supplierId).subscribe({
        next: () => {
          this.toastService.showToast({
            defaultMsg: 'Xóa danh mục sản phẩm thành công!',
            title: 'Thành công',
            type: 'success'
          });
          this.getAllPurchaseOrder();
        },
        error: (error: HttpErrorResponse) => {
          this.toastService.showToast({
            error,
            defaultMsg: 'Xóa danh mục sản phẩm không thành công!',
            title: 'Thông báo',
            delay: 3000,
            type: 'danger'
          });
        }
      });
    }
  }

  toggleDetails(orderId: number) {
    this.expandedOrderId = this.expandedOrderId === orderId ? null : orderId;
  }

  getImageUrl(thumbnail: string): string {
    return `${environment.apiBaseUrl}/products/images/${thumbnail}`;
  }

  getFileUrl(fileName: string): string {
    return this.purchaseOrderService.viewFile(fileName);
  }

  printPdfOnly(fileName: string): void {
    const invoiceUrl = this.getFileUrl(fileName);
    fetch(invoiceUrl)
      .then(response => response.blob())
      .then(blob => {
        const blobUrl = URL.createObjectURL(blob);
        const printWindow = window.open(blobUrl, '_blank');

        printWindow?.addEventListener('load', () => {
          setTimeout(() => {
            printWindow.print();
            // Tự động đóng sau khi in (tùy chọn)
            // printWindow.close();
          }, 500);
        });
      })
      .catch(err => {
        console.error('Lỗi in PDF:', err);
        this.toastService.showToast({
          defaultMsg: 'Không thể in hóa đơn. Vui lòng tải xuống và in thủ công.',
          type: 'warning'
        });
      });
  }

  downloadPdf(fileName: string, orderId: number): void {
    const invoiceUrl = this.getFileUrl(fileName);
    fetch(invoiceUrl)
      .then(response => {
        if (!response.ok) throw new Error('Download failed');
        return response.blob();
      })
      .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `hoa-don-don-hang-${orderId}.pdf`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);

        this.toastService.showToast({
          defaultMsg: 'Đã tải hóa đơn về máy!',
          type: 'success',
          delay: 3000
        });
      })
      .catch(err => {
        console.error('Lỗi tải PDF:', err);
        this.toastService.showToast({
          defaultMsg: 'Không thể tải hóa đơn. Vui lòng thử lại.',
          type: 'danger'
        });
      });
  }

  getAllSupplier() {
    this.supplierService.getAllSupplier().subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.suppliers = response.data;
      },
      complete: () => { debugger },
      error: (error: HttpErrorResponse) => {
        debugger;
        console.error('Error fetching supplier: ', error)
      }
    })
  }

  getQuantityInCart(productId: number): number {
    const item = this.cartItems.find(i => i.productId === productId);
    return item ? item.quantity : 0;
  }

  increaseQuantity(product: Product) {
    const currentInCart = this.getQuantityInCart(product.id);
    const totalAfter = currentInCart + 1;

    if (totalAfter > product.stockQuantity) {
      this.toastService.showToast({
        defaultMsg: `Không thể thêm! Chỉ còn ${product.stockQuantity} sản phẩm trong kho.`,
        type: 'danger'
      });
      return;
    }

    const item = this.cartItems.find(i => i.productId === product.id);
    if (item) {
      item.quantity++;
    } else {
      this.cartItems.push({ productId: product.id, quantity: 1 });
    }
  }

  decreaseQuantity(productId: number) {
    const item = this.cartItems.find(i => i.productId === productId);
    if (item) {
      item.quantity--;
      if (item.quantity <= 0) {
        this.cartItems = this.cartItems.filter(i => i.productId !== productId);
      }
    }
  }

  getTotalMoney(): number {
    return this.cartItems.reduce((total, item) => {
      const product = this.products.find(p => p.id === item.productId);
      return total + (product ? product.price * item.quantity : 0);
    }, 0);
  }

  addProductToCart(productIdStr: string, quantityStr: string) {
    if (!productIdStr) {
      this.toastService.showToast({ defaultMsg: 'Vui lòng chọn sản phẩm', type: 'warning' });
      return;
    }

    const productId = Number(productIdStr);
    const quantity = Number(quantityStr) || 1;

    if (quantity < 1) {
      this.toastService.showToast({ defaultMsg: 'Số lượng phải lớn hơn 0', type: 'warning' });
      return;
    }

    const product = this.products.find(p => p.id === productId);
    if (!product) return;

    const currentInCart = this.getQuantityInCart(productId);
    const totalAfter = currentInCart + quantity;

    if (totalAfter > product.stockQuantity) {
      this.toastService.showToast({
        defaultMsg: `Không thể thêm! Chỉ còn ${product.stockQuantity} sản phẩm trong kho.`,
        type: 'danger'
      });
      return;
    }

    const item = this.cartItems.find(i => i.productId === productId);
    if (item) {
      item.quantity += quantity;
    } else {
      this.cartItems.push({ productId, quantity });
    }

    this.toastService.showToast({
      defaultMsg: `Đã thêm ${quantity} "${product.name}" vào đơn`,
      type: 'success'
    });
  }

  // Tăng số lượng từ bảng
  increaseQuantityFromCart(productId: number) {
    const product = this.products.find(p => p.id === productId);
    if (!product) return;

    const current = this.getQuantityInCart(productId);
    if (current + 1 > product.stockQuantity) {
      this.toastService.showToast({
        defaultMsg: `Không thể tăng! Chỉ còn ${product.stockQuantity} sản phẩm.`,
        type: 'danger'
      });
      return;
    }

    const item = this.cartItems.find(i => i.productId === productId);
    if (item) item.quantity++;
  }

  // Xóa khỏi giỏ
  removeFromCart(productId: number) {
    this.cartItems = this.cartItems.filter(i => i.productId !== productId);
  }

  // Helper functions
  getProductName(productId: number): string {
    return this.products.find(p => p.id === productId)?.name || '—';
  }

  getProductStock(productId: number): number {
    return this.products.find(p => p.id === productId)?.stockQuantity || 0;
  }

  getProductPrice(productId: number): number {
    return this.products.find(p => p.id === productId)?.price || 0;
  }

  getItemTotal(item: CartItemDto): number {
    const price = this.getProductPrice(item.productId);
    return price * item.quantity;
  }

  getMaxQuantity(productIdStr: string): number {
    if (!productIdStr) return 999;
    const productId = Number(productIdStr);
    const product = this.products.find(p => p.id === productId);
    const current = this.getQuantityInCart(productId);
    return product ? product.stockQuantity - current : 999;
  }

  async markAsUsed(invoiceId: number) {
    const result = await this.toastService.showConfirmToast({
      message: 'Bạn có chắc muốn xác nhận đơn đặt hàng này? Sau khi xác nhận sẽ không thể sửa lại.',
      title: 'Xác nhận duyệt',
      type: 'warning',
      okText: 'Duyệt',
      cancelText: 'Hủy'
    });
    if (result) {
      this.supplierInvoiceService.blockOrEnable(invoiceId, 1).subscribe({
        next: () => {
          this.toastService.showToast({
            defaultMsg: 'Đã đánh dấu hóa đơn là ĐÃ SỬ DỤNG (Nhập hàng thành công)!',
            type: 'success',
            delay: 4000
          });
          this.getAllPurchaseOrder(); // Refresh danh sách
        },
        error: (err) => {
          this.toastService.showToast({
            defaultMsg: 'Không thể đánh dấu hóa đơn: ' + (err.error?.message || 'Lỗi server'),
            type: 'danger'
          });
        }
      });
    }
  }
}
