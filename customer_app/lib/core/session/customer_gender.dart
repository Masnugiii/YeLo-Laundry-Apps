enum CustomerGender {
  male,
  female,
  other;

  static CustomerGender? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    return switch (raw.trim().toLowerCase()) {
      'male' || 'm' || 'laki-laki' || 'laki_laki' => CustomerGender.male,
      'female' || 'f' || 'perempuan' => CustomerGender.female,
      'other' => CustomerGender.other,
      _ => null,
    };
  }
}
