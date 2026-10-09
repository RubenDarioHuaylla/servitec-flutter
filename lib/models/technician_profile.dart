class TechnicianProfile {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String location;
  final String description;

  final List<String> categoryIds;

  final int experienceYears;
  final double serviceRadiusKm;

  final bool available;
  final String verificationStatus;

  final double? latitude;
  final double? longitude;
  final String? profileImageUrl;

  const TechnicianProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.location,
    required this.description,
    required this.categoryIds,
    required this.experienceYears,
    required this.serviceRadiusKm,
    required this.available,
    required this.verificationStatus,
    required this.latitude,
    required this.longitude,
    this.profileImageUrl,
  });

  String get fullName => '$firstName $lastName'.trim();
}