import {IsString, IsNotEmpty, IsPhoneNumber, IsDate} from 'class-validator'

export class LoginDto{
    @IsString()
    @IsNotEmpty()
    password: string;

    @IsPhoneNumber()
    phoneNumber:string;

  constructor(data:any){
    this.phoneNumber=data.phoneNumber;
    this.password=data.password;
  }
}