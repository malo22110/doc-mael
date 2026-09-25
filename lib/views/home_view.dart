import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../services/database.dart';
import '../models/report.dart';
import '../models/daily_status.dart';
import '../models/intention.dart';
import '../utils/time_utils.dart';

class HomeView extends StatefulWidget {
  final DatabaseService db;
  final String locationId = 'mael_carhaix';

  const HomeView({super.key, required this.db});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _pseudo = "";

  @override
  void initState() {
    super.initState();
    _loadPseudo();
  }

  Future<void> _loadPseudo() async {
    final prefs = await SharedPreferences.getInstance();
    String? pseudo = prefs.getString('user_pseudo');
    if (pseudo == null) {
      final random = Random();
      pseudo = "Patient_${random.nextInt(10000)}";
      await prefs.setString('user_pseudo', pseudo);
    }
    setState(() {
      _pseudo = pseudo!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bool isOpen = TimeUtils.isOpen(now);
    final DateTime targetDate = TimeUtils.getNextOpenDate(now);
    final String targetDateStr = TimeUtils.toDateString(targetDate);
    final bool isToday = (targetDate.year == now.year && targetDate.month == now.month && targetDate.day == now.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cabinet Médical - Affluence"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_pseudo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Bonjour $_pseudo",
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            
            if (!isOpen) ...[
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_clock, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        "Le cabinet est actuellement fermé.",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Prochaine ouverture :\n${TimeUtils.formatDate(targetDate)}",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Prévisions pour la prochaine ouverture",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Intention>>(
                stream: widget.db.subscribeToIntentions(widget.locationId, targetDateStr),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.red));
                  }
                  
                  final intentions = snapshot.data ?? [];
                  
                  // Filter out any old test slots or invalid slots
                  final validSlots = TimeUtils.getSlotsForDate(targetDate, now);
                  final validIntentions = intentions.where((i) => validSlots.contains(i.timeSlot)).toList();

                  if (validIntentions.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Aucune venue signalée pour le moment.", textAlign: TextAlign.center),
                      ),
                    );
                  }

                  final Map<String, int> grouped = {};
                  for (var intention in validIntentions) {
                    grouped[intention.timeSlot] = (grouped[intention.timeSlot] ?? 0) + 1;
                  }

                  // Sort slots
                  final sortedSlots = grouped.keys.toList()..sort();

                  return Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedSlots.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final slot = sortedSlots[index];
                        final count = grouped[slot]!;
                        return ListTile(
                          leading: const Icon(Icons.schedule),
                          title: Text(slot, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$count patient(s)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ] else ...[
              StreamBuilder<DailyStatus?>(
                stream: widget.db.subscribeToDailyStatus(widget.locationId, targetDateStr),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.red));
                  }
                  final status = snapshot.data;
                  final doctors = status?.activeDoctors ?? 0;
                  return Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.medical_services, size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "$doctors médecin(s) en consultation aujourd'hui",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                "Affluence en salle d'attente",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              StreamBuilder<Report?>(
                stream: widget.db.subscribeToLatestReport(widget.locationId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Erreur Base de données : ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    // return const Center(child: CircularProgressIndicator()); // Removed to avoid infinite loader if stream doesn't emit immediately
                  }
                  final report = snapshot.data;
                  return _buildGauge(context, report);
                },
              ),
            ],
            
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/intentions'),
              icon: const Icon(Icons.calendar_month, size: 32),
              label: Text(
                isOpen ? "J'ai prévu de venir aujourd'hui" : "J'ai prévu de venir à la prochaine ouverture",
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (isOpen)
              OutlinedButton.icon(
                onPressed: () => context.push('/presence?loc=${widget.locationId}'),
                icon: const Icon(Icons.qr_code_scanner, size: 32),
                label: const Text(
                  "Je suis arrivé dans la salle d'attente",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge(BuildContext context, Report? report) {
    if (report == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "Aucune donnée disponible pour le moment.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final now = DateTime.now();
    final difference = now.difference(report.createdAt);
    final isStale = difference.inMinutes > 45;

    Color gaugeColor;
    String statusText;

    if (report.countRange == '0-2' || report.countRange == '3-5') {
      gaugeColor = Colors.green;
      statusText = "Faible à modérée";
    } else if (report.countRange == '6-9') {
      gaugeColor = Colors.orange;
      statusText = "Forte";
    } else {
      gaugeColor = Colors.red;
      statusText = "Très forte";
    }

    if (isStale) {
      gaugeColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gaugeColor, width: 4),
        ),
        child: Column(
          children: [
            Text(
              report.countRange,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: gaugeColor,
              ),
            ),
            const Text("personnes estimées"),
            const SizedBox(height: 8),
            Text(
              statusText.toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: gaugeColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isStale
                  ? "Donnée potentiellement obsolète – Aucun signalement récent"
                  : "Mis à jour il y a ${difference.inMinutes} min",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: isStale ? Colors.grey : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
