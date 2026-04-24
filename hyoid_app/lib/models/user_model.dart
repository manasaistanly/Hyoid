// lib/models/user_model.dart
// ─────────────────────────────────────────────────────────────
// Core user model used across the app.
// Extended with payment and auth provider fields to support
// the new Google OAuth + OTP + Razorpay payment flow.
//
// requiresPayment is derived from the server's isPaid flag and
// is used by AuthGuard and PaymentScreen to control routing.
// ─────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final int? age;
  final String? phone;
  final String? profileImage;
  final String? dateOfBirth;
  final String? emergencyContact;
  final String? gender;
  final String? bloodGroup;
  final String? address;

  // Auth provider: 'email' | 'google' | 'phone'
  final String authProvider;

  // Payment state (synced from server)
  final bool isPaid;
  final bool requiresPayment;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.age,
    this.phone,
    this.profileImage,
    this.dateOfBirth,
    this.emergencyContact,
    this.gender,
    this.bloodGroup,
    this.address,
    this.authProvider = 'email',
    this.isPaid = false,
    this.requiresPayment = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'patient',
      age: json['age'],
      phone: json['phone'],
      profileImage: json['profileImage'],
      dateOfBirth: json['dateOfBirth'],
      emergencyContact: json['emergencyContact'],
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      address: json['address'],
      authProvider: json['authProvider'] ?? 'email',
      isPaid: json['isPaid'] ?? false,
      requiresPayment: json['requiresPayment'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      if (age != null) 'age': age,
      if (phone != null) 'phone': phone,
      if (profileImage != null) 'profileImage': profileImage,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (gender != null) 'gender': gender,
      if (bloodGroup != null) 'bloodGroup': bloodGroup,
      if (address != null) 'address': address,
      'authProvider': authProvider,
      'isPaid': isPaid,
      'requiresPayment': requiresPayment,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    int? age,
    String? phone,
    String? profileImage,
    String? dateOfBirth,
    String? emergencyContact,
    String? gender,
    String? bloodGroup,
    String? address,
    String? authProvider,
    bool? isPaid,
    bool? requiresPayment,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      authProvider: authProvider ?? this.authProvider,
      isPaid: isPaid ?? this.isPaid,
      requiresPayment: requiresPayment ?? this.requiresPayment,
    );
  }
}
