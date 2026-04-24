import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import '../models/doctor_model.dart';
import '../services/consultation_service.dart';
import 'doctor_profile_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = true;
  String _selectedSpecialization = 'All';

  final List<String> _specializations = [
    'All',
    'General Medicine',
    'Cardiology',
    'Dermatology',
    'Pediatrics',
    'Orthopedics',
    'Gynecology',
    'Neurology',
    'Psychiatry',
    'Dentistry',
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _searchController.addListener(_filterDoctors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await ConsultationService.getDoctors();
      setState(() {
        _doctors = doctors;
        _filteredDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load doctors: $e')),
      );
    }
  }

  void _filterDoctors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final matchesSearch = doctor.name.toLowerCase().contains(query) ||
            doctor.specialization.toLowerCase().contains(query);
        final matchesSpecialization = _selectedSpecialization == 'All' ||
            doctor.specialization == _selectedSpecialization;
        return matchesSearch && matchesSpecialization;
      }).toList();
    });
  }

  void _onSpecializationChanged(String specialization) {
    setState(() => _selectedSpecialization = specialization);
    _filterDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Find a Doctor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E2E2E), width: 1.5),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search doctors or specializations...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),

          // Specialization Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _specializations.length,
              itemBuilder: (context, index) {
                final specialization = _specializations[index];
                final isSelected = specialization == _selectedSpecialization;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(specialization),
                    selected: isSelected,
                    onSelected: (selected) => _onSpecializationChanged(specialization),
                    backgroundColor: AppTheme.darkSurface,
                    selectedColor: AppTheme.orangeAccent.withOpacity(0.2),
                    checkmarkColor: AppTheme.orangeAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.orangeAccent : Colors.white70,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),

          // Doctor List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.orangeAccent))
                : _filteredDoctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medical_services_outlined, size: 72, color: Colors.white24),
                            const SizedBox(height: 16),
                            const Text('No doctors found', style: TextStyle(color: Colors.white70, fontSize: 18)),
                            const SizedBox(height: 8),
                            const Text('Try adjusting your search or filters', style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _filteredDoctors[index];
                          return DoctorCard(
                            doctor: doctor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorProfileScreen(doctor: doctor),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter by Specialization', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _specializations.map((spec) {
                final isSelected = spec == _selectedSpecialization;
                return FilterChip(
                  label: Text(spec),
                  selected: isSelected,
                  onSelected: (selected) {
                    _onSpecializationChanged(spec);
                    Navigator.pop(context);
                  },
                  backgroundColor: AppTheme.pureBlack,
                  selectedColor: AppTheme.orangeAccent.withOpacity(0.2),
                  checkmarkColor: AppTheme.orangeAccent,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.orangeAccent : Colors.white70,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2E2E2E), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                // Doctor Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(doctor.profileImage),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: AppTheme.orangeAccent.withOpacity(0.3), width: 2),
                  ),
                  child: doctor.profileImage.isEmpty
                      ? Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.orangeAccent,
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 30),
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Dr. ${doctor.name}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildAvailabilityIndicator(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor.rating.toStringAsFixed(1)} (${doctor.reviewCount})',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            doctor.experience,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${doctor.consultationFee}',
                        style: const TextStyle(color: AppTheme.orangeAccent, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityIndicator() {
    Color color;
    String text;

    switch (doctor.availabilityStatus) {
      case 'available':
        color = Colors.green;
        text = 'Available';
        break;
      case 'busy':
        color = Colors.orange;
        text = 'Busy';
        break;
      default:
        color = Colors.grey;
        text = 'Offline';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}