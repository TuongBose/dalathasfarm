export interface Occasion {
    id: number;
    name: string;
    thumbnail:string;
    description:string;
    bannerImage:string;
    startDate:Date;
    endDate:Date;
    isActive:boolean;
}