import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../services/database.dart';
import '../models/report.dart';
import '../models/daily_status.dart';
import '../models/intention.dart';
import '../utils/time_utils.dart';
import '../utils/pseudo_generator.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      pseudo = BretonPseudoGenerator.generate();
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
        title: SvgPicture.asset(
          'assets/logo_header.svg',
          height: 38,
        ),
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_clock, size: 36, color: Colors.red),
                      const SizedBox(height: 8),
                      const Text(
                        "Le cabinet est actuellement fermé.",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Prochaine ouverture :\n${TimeUtils.formatDate(targetDate)}",
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Prévisions pour la prochaine ouverture",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Intention>>(
                stream: widget.db.subscribeToIntentions(widget.locationId, targetDateStr),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint('Firestore Error (Intentions): ${snapshot.error}');
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Données momentanément indisponibles.", textAlign: TextAlign.center),
                      ),
                    );
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
                          visualDensity: VisualDensity.compact,
                          leading: const Icon(Icons.schedule),
                          title: Text(slot, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$count patient(s)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
                    debugPrint('Firestore Error (DailyStatus): ${snapshot.error}');
                    return const SizedBox.shrink(); // Don't show the doctor card if there's an error
                  }
                  final status = snapshot.data;
                  final doctors = status?.activeDoctors ?? 0;
                  return Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.medical_services, size: 28),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "$doctors médecin(s) en consultation aujourd'hui",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Affluence en salle d'attente",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              StreamBuilder<Report?>(
                stream: widget.db.subscribeToLatestReport(widget.locationId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint('Firestore Error (LatestReport): ${snapshot.error}');
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Données d'affluence momentanément indisponibles.", textAlign: TextAlign.center),
                      ),
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
            
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/intentions'),
              icon: const Icon(Icons.calendar_month, size: 28),
              label: Text(
                isOpen ? "J'ai prévu de venir aujourd'hui" : "J'ai prévu de venir à la prochaine ouverture",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (isOpen)
              OutlinedButton.icon(
                onPressed: () => context.push('/presence?loc=${widget.locationId}'),
                icon: const Icon(Icons.qr_code_scanner, size: 28),
                label: const Text(
                  "Je suis arrivé dans la salle d'attente",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
              ),
              
            const SizedBox(height: 24),
            // Disclaimer
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.grey, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      "Ces données sont fournies par les patients à titre purement indicatif et ne sont pas gérées par le cabinet médical.",
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.push('/about'),
                      child: const Text("À propos et Responsabilité"),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse('https://www.buymeacoffee.com/malobiche');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFDD00),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.coffee, size: 20),
                      label: const Text(
                        "Soutenir le projet",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
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
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gaugeColor, width: 4),
        ),
        child: Column(
          children: [
            Text(
              report.countRange,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: gaugeColor,
              ),
            ),
            const Text("personnes estimées", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              statusText.toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: gaugeColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isStale
                  ? "Potentiellement obsolète"
                  : "Mis à jour il y a ${difference.inMinutes} min",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 13,
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
