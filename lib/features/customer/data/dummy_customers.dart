import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer_order_history.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer_profile.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer_statistics.dart';

const dummyCustomers = <Customer>[
  Customer(
    id: 'cust-001',
    name: 'Andi Saputra',
    phone: '+62 812 3456 7890',
    occupation: 'Pegawai Swasta',
    address: 'Jl. Melati No. 12, Ciputat',
    walletBalance: 150000,
    points: 350,
    isMember: true,
  ),
  Customer(
    id: 'cust-002',
    name: 'Siti Rahayu',
    phone: '+62 813 9876 5432',
    occupation: 'Wiraswasta',
    address: 'Perumahan Griya Asri Blok B7, Pamulang',
    walletBalance: 75000,
    points: 520,
    isMember: true,
  ),
  Customer(
    id: 'cust-003',
    name: 'Budi Santoso',
    phone: '+62 821 1122 3344',
    occupation: 'PNS',
    address: 'Jl. Sudirman No. 45, Jakarta Selatan',
    walletBalance: 0,
    points: 120,
    isMember: false,
  ),
  Customer(
    id: 'cust-004',
    name: 'Dewi Lestari',
    phone: '+62 856 7788 9900',
    occupation: 'Guru',
    address: 'Jl. Mawar No. 8, Serpong',
    walletBalance: 250000,
    points: 890,
    isMember: true,
  ),
  Customer(
    id: 'cust-005',
    name: 'Rizky Pratama',
    phone: '+62 877 6655 4433',
    occupation: 'Mahasiswa',
    address: 'Kost Melati, BSD City',
    walletBalance: 0,
    points: 45,
    isMember: false,
  ),
  Customer(
    id: 'cust-006',
    name: 'Maya Anggraini',
    phone: '+62 811 2233 4455',
    occupation: 'Dokter',
    address: 'Apartemen Skyline Tower 12A, Jakarta',
    walletBalance: 500000,
    points: 1200,
    isMember: true,
  ),
];

final dummyCustomerProfiles = <CustomerProfile>[
  CustomerProfile(
    customer: dummyCustomers[0],
    statistics: CustomerStatistics(
      totalOrders: 24,
      lastOrder: '05 Agustus 2026',
      totalSpending: 1850000,
      averageOrderValue: 77000,
    ),
    recentOrders: [
      CustomerOrderHistoryItem(
        queueNumber: 'A-001',
        laundryService: 'Cuci Kering Lipat',
        orderValue: 65000,
        status: 'Selesai',
        date: '05 Agustus 2026',
      ),
      CustomerOrderHistoryItem(
        queueNumber: 'A-018',
        laundryService: 'Express',
        orderValue: 120000,
        status: 'Diproses',
        date: '02 Agustus 2026',
      ),
      CustomerOrderHistoryItem(
        queueNumber: 'A-012',
        laundryService: 'Bed Cover',
        orderValue: 35000,
        status: 'Selesai',
        date: '28 Juli 2026',
      ),
    ],
  ),
  CustomerProfile(
    customer: dummyCustomers[1],
    statistics: CustomerStatistics(
      totalOrders: 18,
      lastOrder: '04 Agustus 2026',
      totalSpending: 1420000,
      averageOrderValue: 79000,
    ),
    recentOrders: [
      CustomerOrderHistoryItem(
        queueNumber: 'B-003',
        laundryService: 'Cuci Kering Setrika',
        orderValue: 80000,
        status: 'Siap Diambil',
        date: '04 Agustus 2026',
      ),
      CustomerOrderHistoryItem(
        queueNumber: 'B-001',
        laundryService: 'Regular',
        orderValue: 55000,
        status: 'Selesai',
        date: '30 Juli 2026',
      ),
    ],
  ),
  CustomerProfile(
    customer: dummyCustomers[2],
    statistics: CustomerStatistics(
      totalOrders: 8,
      lastOrder: '01 Agustus 2026',
      totalSpending: 480000,
      averageOrderValue: 60000,
    ),
    recentOrders: [
      CustomerOrderHistoryItem(
        queueNumber: 'C-007',
        laundryService: 'Cuci Kering Lipat',
        orderValue: 42000,
        status: 'Selesai',
        date: '01 Agustus 2026',
      ),
    ],
  ),
  CustomerProfile(
    customer: dummyCustomers[3],
    statistics: CustomerStatistics(
      totalOrders: 32,
      lastOrder: '06 Agustus 2026',
      totalSpending: 2680000,
      averageOrderValue: 84000,
    ),
    recentOrders: [
      CustomerOrderHistoryItem(
        queueNumber: 'D-002',
        laundryService: 'Express',
        orderValue: 96000,
        status: 'Dicuci',
        date: '06 Agustus 2026',
      ),
      CustomerOrderHistoryItem(
        queueNumber: 'D-001',
        laundryService: 'Sepatu',
        orderValue: 45000,
        status: 'Selesai',
        date: '03 Agustus 2026',
      ),
    ],
  ),
  CustomerProfile(
    customer: dummyCustomers[4],
    statistics: CustomerStatistics(
      totalOrders: 3,
      lastOrder: '20 Juli 2026',
      totalSpending: 135000,
      averageOrderValue: 45000,
    ),
    recentOrders: [
      CustomerOrderHistoryItem(
        queueNumber: 'E-001',
        laundryService: 'Cuci Kering Lipat',
        orderValue: 35000,
        status: 'Selesai',
        date: '20 Juli 2026',
      ),
    ],
  ),
  CustomerProfile(
    customer: dummyCustomers[5],
    statistics: CustomerStatistics(
      totalOrders: 45,
      lastOrder: '07 Agustus 2026',
      totalSpending: 3920000,
      averageOrderValue: 87000,
    ),
    recentOrders: [
      CustomerOrderHistoryItem(
        queueNumber: 'F-005',
        laundryService: 'Bed Cover',
        orderValue: 70000,
        status: 'Menunggu',
        date: '07 Agustus 2026',
      ),
      CustomerOrderHistoryItem(
        queueNumber: 'F-004',
        laundryService: 'Express',
        orderValue: 144000,
        status: 'Selesai',
        date: '05 Agustus 2026',
      ),
      CustomerOrderHistoryItem(
        queueNumber: 'F-003',
        laundryService: 'Cuci Kering Setrika',
        orderValue: 88000,
        status: 'Selesai',
        date: '01 Agustus 2026',
      ),
    ],
  ),
];

CustomerProfile? findCustomerProfile(String id) {
  for (final profile in dummyCustomerProfiles) {
    if (profile.customer.id == id) {
      return profile;
    }
  }
  return null;
}
