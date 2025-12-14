import { District } from "./district.response";

export interface Province {
  name: string;
  code: number;
  codename: string;
  districts: District[];
}