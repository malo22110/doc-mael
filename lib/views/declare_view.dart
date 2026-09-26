import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../services/database.dart';
import '../models/report.dart';
import '../models/daily_status.dart';

class DeclareView extends StatefulWidget {
  final DatabaseService db;
  final String locationId;
  
  static bool bypassLocationForTesting = false;

  const DeclareView({super.key, required this.db, required this.locationId});

  @override
  State<DeclareView> createState() => _DeclareViewState();
}

class _DeclareViewState extends State<DeclareView> {
  int? _selectedDoctors;
  bool _isCheckingLocation = true;
  bool _isLocationValid = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    if (DeclareView.bypassLocationForTesting) {
      setState(() {
        _isCheckingLocation = false;
        _isLocationValid = true;
      });
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    // Cabinet de Maël-Carhaix
    const targetLat = 48.2568;
    const targetLon = -3.3986;
    const double maxDistanceMeters = 2000; // 2km radius to account for poor GPS/Web location

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() { _isCheckingLocation = false; _locationError = "Les services de localisation sont désactivés. Veuillez les activer."; });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() { _isCheckingLocation = false; _locationError = "L'autorisation de localisation a été refusée."; });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() { _isCheckingLocation = false; _locationError = "Les autorisations de localisation sont refusées définitivement."; });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double distanceInMeters = Geolocator.distanceBetween(position.latitude, position.longitude, targetLat, targetLon);

      if (distanceInMeters <= maxDistanceMeters) {
        if (mounted) setState(() { _isCheckingLocation = false; _isLocationValid = true; });
      } else {
        if (mounted) setState(() { _isCheckingLocation = false; _locationError = "Vous êtes trop éloigné(e) du cabinet médical pour faire une déclaration."; });
      }
    } catch (e) {
      if (mounted) setState(() { _isCheckingLocation = false; _locationError = "Erreur lors de la vérification de votre position."; });
    }
  }

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
    if (_isCheckingLocation) {
      return Scaffold(
        appBar: AppBar(title: const Text("Vérification...")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Vérification de votre position...", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (!_isLocationValid) {
      return Scaffold(
        appBar: AppBar(title: const Text("Déclaration bloquée")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  _locationError ?? "Erreur de localisation",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Pour garantir la fiabilité des données, vous devez être à proximité du cabinet médical pour déclarer l'affluence.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text("Retour à l'accueil"),
                )
              ],
            ),
          ),
        ),
      );
    }

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
