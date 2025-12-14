export class UpdateUserDto {
    fullName: string;    
    address: string;    
    password: string;    
    retypePassword: string;    
    dateOfBirth: Date;    
    
    constructor(data: any) {
        this.fullName = data.fullName;
        this.address = data.address;
        this.password = data.password;
        this.retypePassword = data.retypePassword;
        this.dateOfBirth = data.dateOfBirth;        
    }
}