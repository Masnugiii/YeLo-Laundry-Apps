abstract final class CustomerOccupationOptions {
  static const other = 'Lainnya';

  static const choices = <String>[
    'Pelajar/Mahasiswa',
    'Karyawan Swasta',
    'Pegawai Negeri',
    'Wirausaha',
    'Profesional',
    'Ibu Rumah Tangga',
    'Freelancer',
    'Pekerja Lepas',
    'Tidak Bekerja',
    other,
  ];

  static bool isPredefinedChoice(String value) {
    return choices.contains(value) && value != other;
  }
}
