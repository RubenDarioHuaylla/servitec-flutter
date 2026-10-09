class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String location;
  final String role;
  final String accountStatus;
  final String? profileImageUrl;

  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.location,
    required this.role,
    required this.accountStatus,
    this.profileImageUrl,
  });

  factory AppUser.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return AppUser(
      id: id,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      location: data['location'] as String? ?? '',
      role: data['role'] as String? ?? '',
      accountStatus: data['accountStatus'] as String? ?? '',
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}