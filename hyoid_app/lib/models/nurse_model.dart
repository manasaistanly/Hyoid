class Nurse {
  final String id;
  final String name;
  final String phone;
  final List<String> qualifications;
  final int experience;
  final List<String> specializations;
  final List<String> languages;
  final bool verified;
  final double rating;
  final int reviewCount;
  final double hourlyRate;
  final bool availability;
  final List<double> location; // [longitude, latitude]

  Nurse({
    required this.id,
    required this.name,
    required this.phone,
    required this.qualifications,
    required this.experience,
    required this.specializations,
    required this.languages,
    required this.verified,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.availability,
    required this.location,
  });

  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      qualifications: List<String>.from(json['qualifications']),
      experience: json['experience'],
      specializations: List<String>.from(json['specializations']),
      languages: List<String>.from(json['languages']),
      verified: json['verified'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      hourlyRate: json['hourlyRate'].toDouble(),
      availability: json['availability'],
      location: List<double>.from(json['location']['coordinates']),
    );
  }
}