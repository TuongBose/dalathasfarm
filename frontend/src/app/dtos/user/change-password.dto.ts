export class ChangePasswordDto {
    oldPassword: string;
    newPassword: string;
    retypeNewPassword: string;

    constructor(data: any) {
        this.oldPassword = data.oldPassword;
        this.newPassword = data.newPassword;
        this.retypeNewPassword = data.retypeNewPassword;
    }
}