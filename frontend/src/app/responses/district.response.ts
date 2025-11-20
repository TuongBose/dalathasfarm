import { Ward } from "./ward.response";

export interface District {
  name: string;
  code: number;
  codename: string;
  wards: Ward[];
}