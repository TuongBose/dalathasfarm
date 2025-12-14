import { Injectable } from "@angular/core";

@Injectable({
    providedIn: 'root'
})

export class ToastService {
    constructor() { }

    showToast({ error, defaultMsg: defaultMessage, title = '', delay = 5000, type = 'danger' }: {
        error?: any,
        defaultMsg: string,
        title?: string,
        delay?: number,
        type?: 'success' | 'danger' | 'info' | 'warning'
    }) {
        if (typeof document === 'undefined') {
            // SSR không hỗ trợ document, bỏ qua
            return;
        }

        // Determine the message based on the error object or use the default message
        let message = defaultMessage;
        if (error && error.error && error.error.message) {
            message = error.error.message;
        } else if (error && typeof error === 'string') {
            message = error;
        }

        // Tạo một container cho toast nếu chưa tồn tại
        let toastContainer = document.getElementById('toast-container');
        if (!toastContainer) {
            toastContainer = document.createElement('div');
            toastContainer.id = 'toast-container';
            toastContainer.setAttribute('aria-live', 'polite');
            toastContainer.setAttribute('aria-atomic', 'true');
            toastContainer.style.position = 'fixed';
            toastContainer.style.top = '0';
            toastContainer.style.right = '0';
            toastContainer.style.padding = '20px';
            document.body.appendChild(toastContainer);
        }

        // Tạo toast element
        const toast = document.createElement('div');
        toast.classList.add('toast', 'show', `bg-${type}`, 'text-white');
        toast.setAttribute('role', 'alert');
        toast.setAttribute('aria-live', 'assertive');
        toast.setAttribute('aria-atomic', 'true');
        toast.style.minWidth = '250px';
        toast.style.marginBottom = '1rem';

        // Nội dung toast
        toast.innerHTML = `
      <div class="toast-header" style="position: relative;">
        <strong class="mr-auto">${title}</strong>
        <button type="button" 
          class="close" data-dismiss="toast" 
          aria-label="Close" 
          style="position: absolute; top: 0; right: 0; padding: 8px 12px; background-color: transparent; border: none; color: black;">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="toast-body">
        ${message}
      </div>
    `;

        // Thêm vào container
        toastContainer.appendChild(toast);

        // Tự động ẩn sau delay
        setTimeout(() => {
            toast.classList.remove('show');
            toastContainer.removeChild(toast);
        }, delay);

        // Xử lý sự kiện đóng khi nhấn vào button close
        toast?.querySelector('.close')?.addEventListener('click', () => {
            toast.classList.remove('show');
            toastContainer.removeChild(toast);
        });
    }

    async showConfirmToast({
        message = 'Bạn có chắc không?',
        title = 'Xác nhận',
        okText = 'OK',
        cancelText = 'Hủy',
        type = 'warning',
        delay = 0 // Không auto-hide
    }: {
        message?: string,
        title?: string,
        okText?: string,
        cancelText?: string,
        type?: 'success' | 'danger' | 'info' | 'warning',
        delay?: number
    }): Promise<boolean> {
        return new Promise(resolve => {
            if (typeof document === 'undefined') return resolve(false);

            // Tạo container nếu chưa có
            let toastContainer = document.getElementById('toast-container');
            if (!toastContainer) {
                toastContainer = document.createElement('div');
                toastContainer.id = 'toast-container';
                toastContainer.style.position = 'fixed';
                toastContainer.style.top = '0';
                toastContainer.style.right = '0';
                toastContainer.style.padding = '20px';
                toastContainer.style.zIndex = '99999';
                document.body.appendChild(toastContainer);
            }

            // Tạo toast
            const toast = document.createElement('div');
            toast.classList.add('toast', 'show', `bg-${type}`, 'text-black');
            toast.style.minWidth = '300px';
            toast.style.paddingBottom = '10px';
            toast.style.marginBottom = '1rem';

            toast.innerHTML = `
            <div class="toast-header">
                <strong class="mr-auto">${title}</strong>
                <button type="button" class="close" aria-label="Close"
                    style="position: absolute; right: 10px; background: none; border: none;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="toast-body">
                ${message}
                <div style="display: flex; justify-content: flex-end; margin-top: 10px; gap: 10px;">
                    <button class="btn btn-light btn-sm btn-cancel">${cancelText}</button>
                    <button class="btn btn-dark btn-sm btn-ok">${okText}</button>
                </div>
            </div>
        `;

            toastContainer.appendChild(toast);

            // Sự kiện OK
            toast.querySelector('.btn-ok')?.addEventListener('click', () => {
                toast.classList.remove('show');
                toastContainer.removeChild(toast);
                resolve(true);
            });

            // Sự kiện Cancel
            toast.querySelector('.btn-cancel')?.addEventListener('click', () => {
                toast.classList.remove('show');
                toastContainer.removeChild(toast);
                resolve(false);
            });

            // Nút X
            toast.querySelector('.close')?.addEventListener('click', () => {
                toast.classList.remove('show');
                toastContainer.removeChild(toast);
                resolve(false);
            });

            // Không tự động hide nếu delay = 0
            if (delay > 0) {
                setTimeout(() => {
                    if (toastContainer.contains(toast)) {
                        toastContainer.removeChild(toast);
                        resolve(false);
                    }
                }, delay);
            }
        });
    }
}