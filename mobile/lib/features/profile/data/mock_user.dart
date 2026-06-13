class MockUser {
  const MockUser({
    required this.nameFa,
    required this.nameEn,
    required this.phone,
  });

  final String nameFa;
  final String nameEn;
  final String phone;

  String name(String locale) => locale == 'fa' ? nameFa : nameEn;

  String get initials {
    final parts = nameEn.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : 'U';
  }
}

const kMockUser = MockUser(
  nameFa: 'علی رضایی',
  nameEn: 'Ali Rezaei',
  phone: '+98 912 345 6789',
);
