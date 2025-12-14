import {IsString, IsNotEmpty, IsPhoneNumber, IsDate} from 'class-validator'

export class RegisterDto{
    @IsString()
    @IsNotEmpty()
    password: string;

    @IsString()
    @IsNotEmpty()
    retypePassword: string;

    email:string;

    @IsString()
    fullName:string;

    @IsString()
    address:string;

    @IsPhoneNumber()
    phoneNumber:string;

    @IsDate()
    dateOfBirth:Date;

  constructor(data:any){
    this.phoneNumber=data.phoneNumber;
    this.password=data.password;
    this.retypePassword=data.retypePassword;
    this.fullName=data.fullName;
    this.email=data.email;
    this.address=data.address;
    this.dateOfBirth=data.dateOfBirth;
  }
}