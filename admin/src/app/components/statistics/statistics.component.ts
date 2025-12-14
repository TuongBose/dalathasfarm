// // src/app/statistics/statistics.component.ts
// import { Component, OnInit, AfterViewInit, ElementRef, ViewChild, NgModule } from '@angular/core';
// import { Chart } from 'chart.js/auto';
// import { StatisticService } from '../../services/statistic.service';
// import { FormsModule } from '@angular/forms';
// import { CommonModule, formatCurrency } from '@angular/common';

// @Component({
//   selector: 'app-statistics',
//   standalone: true,
//   templateUrl: './statistics.component.html',
//   styleUrls: ['./statistics.component.css'],
//   imports:[
//     FormsModule,
//     CommonModule
//   ]
// })
// export class StatisticsComponent implements OnInit, AfterViewInit {
//   @ViewChild('barChartCanvas') barChartCanvas!: ElementRef<HTMLCanvasElement>;
//   @ViewChild('pieChartCanvas') pieChartCanvas!: ElementRef<HTMLCanvasElement>;

//   currentMonth: string = '';
//   totalRevenue: number = 0;
//   mostBookedMovie: any = null;
//   secondMostBookedMovie: any = null;
//   thirdMostBookedMovie: any = null;
//   mostBookedCinema: any = null;
//   errorMessage: string = '';

//   private barChart: Chart<'bar', number[], string> | undefined;
//   private pieChart: Chart<'pie', number[], string> | undefined;

//   constructor(private statisticService: StatisticService) {}

//   ngOnInit(): void {
//     const today = new Date();
//     const year = today.getFullYear();
//     const month = (today.getMonth() + 1).toString().padStart(2, '0');
//     this.currentMonth = `${month}-${year}`;

//     this.fetchStatistics();
//   }

//   ngAfterViewInit(): void {
//     this.createCharts();
//   }

//   fetchStatistics() {
//     this.statisticService.getMonthlyStatistics().subscribe({
//       next: (data) => {
//         console.log('Statistics data:', data);
//         this.totalRevenue = data.totalRevenue || 0;
//         this.mostBookedMovie = data.mostBookedMovie || null;
//         this.secondMostBookedMovie = data.secondMostBookedMovie || null;
//         this.thirdMostBookedMovie = data.thirdMostBookedMovie || null;
//         this.mostBookedCinema = data.mostBookedCinema || null;

//         this.updateCharts();
//       },
//       error: (error) => {
//         console.error('Error fetching statistics:', error);
//         this.errorMessage = error.error || 'Không thể tải dữ liệu thống kê.';
//         this.totalRevenue = 0;
//         this.mostBookedMovie = null;
//         this.secondMostBookedMovie = null;
//         this.thirdMostBookedMovie = null;
//         this.mostBookedCinema = null;

//         this.updateCharts();
//       },
//     });
//   }

//   createCharts(): void {
//     this.barChart = new Chart(this.barChartCanvas.nativeElement, {
//       type: 'bar',
//       data: {
//         labels: [],
//         datasets: [
//           {
//             label: 'Số lượng vé',
//             data: [],
//             backgroundColor: ['#007bff', '#28a745', '#dc3545'],
//             borderColor: ['#0056b3', '#1e7e34', '#a71d2a'],
//             borderWidth: 1,
//           },
//         ],
//       },
//       options: {
//         responsive: true,
//         scales: {
//           y: {
//             beginAtZero: true,
//             title: {
//               display: true,
//               text: 'Số lượng vé',
//             },
//           },
//         },
//         plugins: {
//           legend: {
//             display: false,
//           },
//         },
//       },
//     });

//     this.pieChart = new Chart(this.pieChartCanvas.nativeElement, {
//       type: 'pie',
//       data: {
//         labels: [],
//         datasets: [
//           {
//             data: [],
//             backgroundColor: ['#007bff', '#28a745', '#dc3545'],
//           },
//         ],
//       },
//       options: {
//         responsive: true,
//         plugins: {
//           legend: {
//             display: true,
//             position: 'top',
//           },
//         },
//       },
//     });
//   }

//   updateCharts(): void {
//     const labels = [
//       this.mostBookedMovie?.movieName || 'Không có dữ liệu',
//       this.secondMostBookedMovie?.movieName || 'Không có dữ liệu',
//       this.thirdMostBookedMovie?.movieName || 'Không có dữ liệu',
//     ];
//     const data = [
//       this.mostBookedMovie?.totalBookings ?? 0,
//       this.secondMostBookedMovie?.totalBookings ?? 0,
//       this.thirdMostBookedMovie?.totalBookings ?? 0,
//     ].map(value => Number(value));

//     if (this.barChart) {
//       this.barChart.data.labels = labels;
//       this.barChart.data.datasets[0].data = data;
//       this.barChart.update();
//     }

//     if (this.pieChart) {
//       this.pieChart.data.labels = labels;
//       this.pieChart.data.datasets[0].data = data;
//       this.pieChart.update();
//     }
//   }
// }

import { Component, OnInit, ViewChild, AfterViewInit } from '@angular/core';
import { Chart, ChartConfiguration, ChartItem } from 'chart.js';

@Component({
  selector: 'app-statistics',
  templateUrl: './statistics.component.html',
  styleUrls: ['./statistics.component.css']
})
export class StatisticsComponent implements OnInit, AfterViewInit {

  // Dữ liệu cho các KPI cards
  dashboardCards = [
    { title: 'Tổng doanh thu tháng', value: '85,000,000 VND' },
    { title: 'Đơn hàng thành công', value: 423 },
    { title: 'Số bó hoa đã bán', value: 1240 },
    { title: 'Sản phẩm hết hàng', value: 3 }
  ];

  // Sản phẩm sắp hết hàng
  lowStockProducts = [
    { name: 'Hoa Hồng Đỏ Premium', stock: 8 },
    { name: 'Tulip Trắng', stock: 5 },
    { name: 'Hoa Baby Mix', stock: 12 }
  ];

  // Biểu đồ Chart.js
  @ViewChild('revenueLineChart') revenueLineChart!: any;
  @ViewChild('bestSellerChart') bestSellerChart!: any;
  @ViewChild('flowerTypeChart') flowerTypeChart!: any;

  constructor() { }

  ngOnInit(): void { }

  ngAfterViewInit(): void {
    this.initRevenueChart();
    this.initBestSellerChart();
    this.initFlowerTypeChart();
  }

  initRevenueChart() {
    const labels = Array.from({length: 30}, (_, i) => `Ngày ${i+1}`);
    const data = Array.from({length: 30}, () => Math.floor(Math.random() * 5000000) + 1000000);

    new Chart(this.revenueLineChart.nativeElement as ChartItem, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: 'Doanh thu',
          data: data,
          borderColor: 'rgba(75, 192, 192, 1)',
          backgroundColor: 'rgba(75, 192, 192, 0.2)',
          fill: true,
          tension: 0.3
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            display: true
          }
        }
      }
    });
  }

  initBestSellerChart() {
    const labels = ['Hoa Hồng Đỏ', 'Lẵng Hoa Chúc Mừng', 'Bó Hoa Tulip Mini'];
    const data = [120, 80, 65];

    new Chart(this.bestSellerChart.nativeElement as ChartItem, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Số lượng bán',
          data: data,
          backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56']
        }]
      },
      options: {
        responsive: true
      }
    });
  }

  initFlowerTypeChart() {
    const labels = ['Hoa Hồng', 'Tulip', 'Baby', 'Lan Hồ Điệp', 'Hoa Mix'];
    const data = [400, 250, 150, 100, 120];

    new Chart(this.flowerTypeChart.nativeElement as ChartItem, {
      type: 'pie',
      data: {
        labels: labels,
        datasets: [{
          label: 'Loại hoa',
          data: data,
          backgroundColor: [
            '#FF6384',
            '#36A2EB',
            '#FFCE56',
            '#4BC0C0',
            '#9966FF'
          ]
        }]
      },
      options: {
        responsive: true
      }
    });
  }

}
