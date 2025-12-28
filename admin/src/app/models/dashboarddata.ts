interface DashboardData {
  lowStockProducts: any[];
  stats: {
    revenueToday: number;
    ordersToday: number;
    revenueWeek: number;
    ordersWeek: number;
    revenueMonth: number;
    ordersMonth: number;
  };
  newCustomersThisMonth: number;
  last10DaysRevenue: DailyRevenue[];
  topProductsToday: TopProduct[];
  topProductsWeek: TopProduct[];
  topProductsMonth: TopProduct[];
}