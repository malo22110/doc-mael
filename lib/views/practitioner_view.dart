import 'package:flutter/material.dart';
import '../services/database.dart';
import '../models/daily_status.dart';

class PractitionerView extends StatefulWidget {
  final DatabaseService db;
  final String locationId = 'mael_carhaix';

  const PractitionerView({super.key, required this.db});

  @override
  State<PractitionerView> createState() => _PractitionerViewState();
}

class _PractitionerViewState extends State<PractitionerView> {
  String _getTargetDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _updateDoctors(int count) async {
    final status = DailyStatus(
      date: _getTargetDate(),
      activeDoctors: count,
      lastUpdatedBy: 'practitioner',
      updatedAt: DateTime.now(),
    );
    await widget.db.updateDailyStatus(widget.locationId, status);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour : $count médecin(s)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Espace Praticien")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Combien de médecins consultent actuellement ?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            StreamBuilder<DailyStatus?>(
              stream: widget.db.subscribeToDailyStatus(widget.locationId, _getTargetDate()),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Firestore Error (PractitionerView): ${snapshot.error}');
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Erreur de connexion. Veuillez réessayer plus tard.", textAlign: TextAlign.center),
                  );
                }
                final currentCount = snapshot.data?.activeDoctors ?? 0;
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [1, 2, 3, 4].map((count) {
                    final isSelected = count == currentCount;
                    return InkWell(
                      onTap: () => _updateDoctors(count),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.teal : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
