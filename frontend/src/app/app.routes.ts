import { Routes } from '@angular/router';
import { HomeComponent } from './components/home/home.component';
import { LoginComponent } from './components/login/login.component';
import { PaymentCallbackComponent } from './components/payment-callback/payment-callback.component';
import { RegisterComponent } from './components/register/register.component';
import { DetailProductComponent } from './components/detail-product/detail-product.component';
import { OrderComponent } from './components/order/order.component';
import { AuthGuardFn } from './guards/auth.guard';
import { UserProfileComponent } from './components/user-profile/user-profile.component';
import { IntroduceComponent } from './components/introduce/introduce.component';
import { ContactComponent } from './components/contact/contact.component';
import { NotificationComponent } from './components/notification/notification.component';
import { OrderConfirmComponent } from './components/order-confirm/order-confirm.component';
import { PrivacyPolicyComponent } from './components/privacy-policy/privacy-policy.component';
import { TermsOfServiceComponent } from './components/terms-of-service/terms-of-service.component';
import { CategoriesComponent } from './components/categories/categories.component';
import { CategoryComponent } from './components/category/category.component';

export const routes: Routes = [
    { path: '', component: HomeComponent },
    { path: 'login', component: LoginComponent },
    { path: 'payments/payment-callback', component: PaymentCallbackComponent },
    { path: 'register', component: RegisterComponent },
    { path: 'products/:id', component: DetailProductComponent },
    { path: 'orders', component: OrderComponent, canActivate: [AuthGuardFn] },
    { path: 'user-profile', component: UserProfileComponent, canActivate: [AuthGuardFn] },
    { path: 'introduce', component: IntroduceComponent },
    { path: 'contact', component: ContactComponent },
    { path: 'notification', component: NotificationComponent },
    { path: 'orders/:id', component: OrderConfirmComponent },
    { path: 'privacy-policy', component: PrivacyPolicyComponent },
    { path: 'terms-of-service', component: TermsOfServiceComponent },
    { path: 'categories', component: CategoriesComponent },
    { path: 'category/:id', component: CategoryComponent },
];
