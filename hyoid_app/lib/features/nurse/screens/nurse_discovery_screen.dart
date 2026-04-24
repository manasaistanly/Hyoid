import 'package:flutter/material.dart';
import '../../../models/nurse_model.dart';
import '../../../services/nurse_service.dart';
import 'nurse_profile_screen.dart';

class NurseDiscoveryScreen extends StatefulWidget {
  const NurseDiscoveryScreen({super.key});

  @override
  _NurseDiscoveryScreenState createState() => _NurseDiscoveryScreenState();
}

class _NurseDiscoveryScreenState extends State<NurseDiscoveryScreen> {
  List<Nurse> nurses = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedService = '';
  int minExperience = 0;
  double minRating = 0.0;
  String sortBy = 'rating';

  @override
  void initState() {
    super.initState();
    loadNurses();
  }

  Future<void> loadNurses() async {
    setState(() => isLoading = true);
    try {
      final fetchedNurses = await NurseService.getNurses(
        service: selectedService.isNotEmpty ? selectedService : null,
        experience: minExperience > 0 ? minExperience : null,
        rating: minRating > 0 ? minRating : null,
        sort: sortBy,
      );
      if (!mounted) return;
      setState(() {
        nurses = fetchedNurses;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load nurses')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Nurses'),
        actions: [
          IconButton(icon: Icon(Icons.filter_list), onPressed: _showFilters),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by service (e.g., injection, wound care)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
                loadNurses();
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : nurses.isEmpty
                ? Center(child: Text('No nurses found'))
                : ListView.builder(
                    itemCount: nurses.length,
                    itemBuilder: (context, index) {
                      final nurse = nurses[index];
                      return NurseCard(
                        nurse: nurse,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NurseProfileScreen(nurse: nurse),
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

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: selectedService.isNotEmpty ? selectedService : null,
                    hint: Text('Select Service'),
                    items:
                        [
                              'injection',
                              'wound care',
                              'elderly care',
                              'post-surgery care',
                            ]
                            .map(
                              (service) => DropdownMenuItem(
                                value: service,
                                child: Text(service),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => selectedService = value ?? ''),
                  ),
                  Slider(
                    value: minExperience.toDouble(),
                    min: 0,
                    max: 20,
                    divisions: 20,
                    label: '$minExperience years',
                    onChanged: (value) =>
                        setState(() => minExperience = value.toInt()),
                  ),
                  Slider(
                    value: minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: minRating.toStringAsFixed(1),
                    onChanged: (value) => setState(() => minRating = value),
                  ),
                  DropdownButton<String>(
                    value: sortBy,
                    items: ['price', 'rating', 'distance']
                        .map(
                          (sort) =>
                              DropdownMenuItem(value: sort, child: Text(sort)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => sortBy = value ?? 'rating'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      loadNurses();
                    },
                    child: Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class NurseCard extends StatelessWidget {
  final Nurse nurse;
  final VoidCallback onTap;

  const NurseCard({super.key, required this.nurse, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(
            'assets/images/nurse_placeholder.png',
          ), // Placeholder
        ),
        title: Row(
          children: [
            Text(nurse.name),
            if (nurse.verified)
              Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${nurse.experience} years experience'),
            Text(nurse.specializations.join(', ')),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Text('${nurse.rating} (${nurse.reviewCount} reviews)'),
              ],
            ),
          ],
        ),
        trailing: Text('₹${nurse.hourlyRate}/hr'),
        onTap: onTap,
      ),
    );
  }
}
