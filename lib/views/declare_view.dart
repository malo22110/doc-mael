import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/database.dart';
import '../models/report.dart';
import '../models/daily_status.dart';

class DeclareView extends StatefulWidget {
  final DatabaseService db;
  final String locationId;

  const DeclareView({super.key, required this.db, required this.locationId});

  @override
  State<DeclareView> createState() => _DeclareViewState();
}

class _DeclareViewState extends State<DeclareView> {
  int? _selectedDoctors;

  String _getTargetDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _submitReport(String range) async {
    final report = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple id
      locationId: widget.locationId,
      countRange: range,
      createdAt: DateTime.now(),
      origin: 'qr_scan',
      deviceHash: 'anonymous_hash', // In reality, generate a hash or leave anonymous
    );
    
    await widget.db.addReport(report);

    if (_selectedDoctors != null) {
      final status = DailyStatus(
        date: _getTargetDate(),
        activeDoctors: _selectedDoctors!,
        lastUpdatedBy: 'patient_collab',
        updatedAt: DateTime.now(),
      );
      await widget.db.updateDailyStatus(widget.locationId, status);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci pour votre signalement !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Déclarer l'affluence"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Combien de médecins consultent aujourd'hui ?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [1, 2, 3, 4].map((count) {
                return ChoiceChip(
                  label: Text("$count", style: const TextStyle(fontSize: 24)),
                  padding: const EdgeInsets.all(16),
                  selected: _selectedDoctors == count,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDoctors = selected ? count : null;
                    });
                  },
                );
              }).toList(),
            ),
            const Divider(height: 48),
            const Text(
              "Combien de personnes patientent en salle d'attente ?",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildOption("0 - 5 personnes", "0-5", Colors.green),
            const SizedBox(height: 16),
            _buildOption("6 - 10 personnes", "6-10", Colors.lightGreen),
            const SizedBox(height: 16),
            _buildOption("11 - 15 personnes", "11-15", Colors.orange),
            const SizedBox(height: 16),
            _buildOption("16 - 20 personnes", "16-20", Colors.red),
            const SizedBox(height: 16),
            _buildOption("+ de 20 personnes", "20+", Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String label, String value, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color, width: 3),
        ),
      ),
      onPressed: () => _submitReport(value),
      child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}
