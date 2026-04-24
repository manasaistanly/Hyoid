class UserProfile {
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String dob;
  final String bloodGroup;
  final String emergencyContact;
  final String role;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.dob,
    required this.bloodGroup,
    required this.emergencyContact,
    required this.role,
  });

  factory UserProfile.empty() {
    return const UserProfile(
      userId: '',
      name: '',
      phone: '',
      email: '',
      dob: '',
      bloodGroup: '',
      emergencyContact: '',
      role: 'patient',
    );
  }

  factory UserProfile.fromMap(Map<String, String> map) {
    return UserProfile(
      userId: map['user_id'] ?? '',
      name: map['user_name'] ?? '',
      phone: map['user_phone'] ?? '',
      email: map['user_email'] ?? '',
      dob: map['user_dob'] ?? '',
      bloodGroup: map['user_blood_group'] ?? '',
      emergencyContact: map['user_emergency_contact'] ?? '',
      role: map['user_role'] ?? 'patient',
    );
  }

  Map<String, String> toMap() {
    return {
      'user_id': userId,
      'user_name': name,
      'user_phone': phone,
      'user_email': email,
      'user_dob': dob,
      'user_blood_group': bloodGroup,
      'user_emergency_contact': emergencyContact,
      'user_role': role,
    };
  }

  String get initials {
    if (name.isEmpty) return 'P';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  bool get hasDetails {
    return name.isNotEmpty || phone.isNotEmpty || dob.isNotEmpty || bloodGroup.isNotEmpty || emergencyContact.isNotEmpty;
  }
}
