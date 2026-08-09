import 'package:yelo_laundry_erp/features/settings/models/laundry_profile.dart';

LaundryProfile _laundryProfile = const LaundryProfile(
  name: 'YELO LAUNDRY',
  address: 'Jl. Ahmad Yani No.123',
  city: 'Probolinggo',
  whatsapp: '0812-3456-7890',
  instagram: '@yelolaundry',
  website: 'www.yelolaundry.com',
);

LaundryProfile getLaundryProfile() => _laundryProfile;

void saveLaundryProfile(LaundryProfile profile) {
  _laundryProfile = profile;
}

void resetLaundryProfileForTesting() {
  _laundryProfile = const LaundryProfile(
    name: 'YELO LAUNDRY',
    address: 'Jl. Ahmad Yani No.123',
    city: 'Probolinggo',
    whatsapp: '0812-3456-7890',
    instagram: '@yelolaundry',
    website: 'www.yelolaundry.com',
  );
}
