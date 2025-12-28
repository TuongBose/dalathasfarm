import { Routes } from '@angular/router';
import { HomeComponent } from './components/home/home.component';
import { LoginComponent } from './components/login/login.component';
import { ProductsComponent } from './components/products/products.component';
import { CategoriesComponent } from './components/categories/categories.component';
import { OccasionsComponent } from './components/occasions/occasions.component';
import { OrdersComponent } from './components/orders/orders.component';
import { SuppliersComponent } from './components/suppliers/suppliers.component';
import { CustomersComponent } from './components/customers/customers.component';
import { AdminsComponent } from './components/admins/admins.component';
import { EmployeesComponent } from './components/employees/employees.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { AuthGuardFn } from './guard/auth.guard';
import { SupplierOrderComponent } from './components/supplier-order/supplier-order.component';
import { SupplierInvoiceComponent } from './components/supplier-invoice/supplier-invoice.component';
import { PurchaseOrderComponent } from './components/purchase-order/purchase-order.component';
import { CouponManagementComponent } from './components/coupon-management/coupon-management.component';

export const routes: Routes = [

  { path: 'login', component: LoginComponent },
  {
    path: 'home',
    component: HomeComponent,
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' }, // trang mặc định khi vào /home
      { path: 'dashboard', component: DashboardComponent },
      { path: 'products', component: ProductsComponent },
      { path: 'categories', component: CategoriesComponent },    // Quản lý danh mục
      { path: 'occasions', component: OccasionsComponent },     // Quản lý dịp lễ
      { path: 'orders', component: OrdersComponent },        // Quản lý đơn hàng
      { path: 'suppliers', component: SuppliersComponent },     // Quản lý nhà cung cấp
      { path: 'supplier-orders', component: SupplierOrderComponent },
      { path: 'supplier-invoices', component: SupplierInvoiceComponent },
      { path: 'purchase-orders', component: PurchaseOrderComponent },
      { path: 'customers', component: CustomersComponent, canActivate: [AuthGuardFn] },
      { path: 'admins', component: AdminsComponent, canActivate: [AuthGuardFn] },
      { path: 'employees', component: EmployeesComponent, canActivate: [AuthGuardFn] },
      { path: 'coupons', component: CouponManagementComponent },
    ]
  },
  { path: '', redirectTo: '/home', pathMatch: 'full' },
  { path: '**', redirectTo: '/home' },
  // { path: 'products', component: ProductsComponent },
  // { path: 'statistics', component: StatisticsComponent },
  // { path: 'payments/payment-callback', component: PaymentCallbackComponent },
  // { path: 'payment-success', component: PaymentSuccessComponent },
  // { path: 'register', component: RegisterComponent },
  // { path: 'products/:id', component: DetailProductComponent },
  // { path: 'orders', component: OrderComponent },
  // { path: 'orders-history', component: OrderHistoryComponent, canActivate: [AuthGuardFn] },
  // { path: 'user-profile', component: UserProfileComponent, canActivate: [AuthGuardFn] },
  // { path: 'introduce', component: IntroduceComponent },
  // { path: 'contact', component: ContactComponent },
  // { path: 'notification', component: NotificationComponent },
  // { path: 'order-invoice', component: OrderSearchComponent },
  // { path: 'privacy-policy', component: PrivacyPolicyComponent },
  // { path: 'terms-of-service', component: TermsOfServiceComponent },
  // { path: 'categories', component: CategoriesComponent },
  // { path: 'category/:id', component: CategoryComponent },
  // { path: 'occasions', component: OccasionsComponent },
  // { path: 'occasion/:id', component: OccasionComponent },
  // { path: 'product-search', component: ProductSearchComponent },
];