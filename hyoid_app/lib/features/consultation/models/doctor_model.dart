class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final int reviewCount;
  final String profileImage;
  final String bio;
  final List<String> qualifications;
  final List<String> languages;
  final String availabilityStatus; // 'available', 'busy', 'offline'
  final List<TimeSlot> availableSlots;
  final bool isOnline;
  final int consultationFee;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.reviewCount,
    required this.profileImage,
    required this.bio,
    required this.qualifications,
    required this.languages,
    required this.availabilityStatus,
    required this.availableSlots,
    required this.isOnline,
    required this.consultationFee,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      specialization: json['specialization'],
      experience: json['experience'],
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      profileImage: json['profileImage'],
      bio: json['bio'],
      qualifications: List<String>.from(json['qualifications'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      availabilityStatus: json['availabilityStatus'] ?? 'offline',
      availableSlots: (json['availableSlots'] as List<dynamic>?)
          ?.map((slot) => TimeSlot.fromJson(slot))
          .toList() ?? [],
      isOnline: json['isOnline'] ?? false,
      consultationFee: json['consultationFee'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'experience': experience,
      'rating': rating,
      'reviewCount': reviewCount,
      'profileImage': profileImage,
      'bio': bio,
      'qualifications': qualifications,
      'languages': languages,
      'availabilityStatus': availabilityStatus,
      'availableSlots': availableSlots.map((slot) => slot.toJson()).toList(),
      'isOnline': isOnline,
      'consultationFee': consultationFee,
    };
  }
}

class TimeSlot {
  final DateTime dateTime;
  final bool isAvailable;

  TimeSlot({
    required this.dateTime,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      dateTime: DateTime.parse(json['dateTime']),
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }
}