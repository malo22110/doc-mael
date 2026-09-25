import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database.dart';
import '../models/intention.dart';
import '../utils/time_utils.dart';

class IntentionsView extends StatefulWidget {
  final DatabaseService db;
  final String locationId = 'mael_carhaix';

  const IntentionsView({super.key, required this.db});

  @override
  State<IntentionsView> createState() => _IntentionsViewState();
}

class _IntentionsViewState extends State<IntentionsView> {
  String? _selectedSlot;
  bool _isLoadingLocal = true;
  String? _activeBookedDate;
  String? _activeBookedSlot;
  String? _activeIntentionId; // ADDED

  @override
  void initState() {
    super.initState();
    _checkActiveIntention();
  }

  Future<void> _checkActiveIntention() async {
    final prefs = await SharedPreferences.getInstance();
    final bookedDate = prefs.getString('booked_intention_date');
    final bookedSlot = prefs.getString('booked_intention_slot');
    final bookedId = prefs.getString('booked_intention_id');

    if (bookedDate != null && bookedSlot != null && bookedId != null) {
      final parts = bookedDate.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        
        final timeParts = bookedSlot.split(' - ')[1].split(':');
        final endHour = int.parse(timeParts[0]);
        final endMinute = int.parse(timeParts[1]);
        
        final slotEnd = DateTime(year, month, day, endHour, endMinute);
        
        if (DateTime.now().isBefore(slotEnd)) {
          setState(() {
            _activeBookedDate = bookedDate;
            _activeBookedSlot = bookedSlot;
            _activeIntentionId = bookedId;
          });
        } else {
          // Clean up old intention
          await prefs.remove('booked_intention_date');
          await prefs.remove('booked_intention_slot');
          await prefs.remove('booked_intention_id');
        }
      }
    }
    setState(() {
      _isLoadingLocal = false;
    });
  }

  bool _isSubmitting = false;

  Future<void> _submitIntention(DateTime targetDate, String targetDateStr) async {
    if (_selectedSlot == null || _isSubmitting) return;
    setState(() { _isSubmitting = true; });

    final intentionId = DateTime.now().millisecondsSinceEpoch.toString();
    final intention = Intention(
      id: intentionId,
      locationId: widget.locationId,
      targetDate: targetDateStr,
      timeSlot: _selectedSlot!,
      createdAt: DateTime.now(),
    );
    await widget.db.addIntention(intention);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('booked_intention_date', targetDateStr);
    await prefs.setString('booked_intention_slot', _selectedSlot!);
    await prefs.setString('booked_intention_id', intentionId);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _activeBookedDate = targetDateStr;
        _activeBookedSlot = _selectedSlot;
        _activeIntentionId = intentionId;
      });
    }
  }

  Future<void> _cancelIntention() async {
    if (_activeIntentionId == null) return;
    
    // Delete from DB
    await widget.db.deleteIntention(_activeIntentionId!);

    // Clear local prefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('booked_intention_date');
    await prefs.remove('booked_intention_slot');
    await prefs.remove('booked_intention_id');

    if (mounted) {
      setState(() {
        _activeBookedDate = null;
        _activeBookedSlot = null;
        _activeIntentionId = null;
        _selectedSlot = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre venue a bien été annulée.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final targetDate = TimeUtils.getNextOpenDate(now);
    final targetDateStr = TimeUtils.toDateString(targetDate);
    final slots = TimeUtils.getSlotsForDate(targetDate, now);

    return Scaffold(
      appBar: AppBar(title: const Text("Prévisions")),
      body: _isLoadingLocal 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                TimeUtils.formatDate(targetDate),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            
            if (slots.isEmpty) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "Aucun créneau disponible pour cette journée.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ] else if (_activeBookedSlot != null) ...[
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Vous avez signalé votre venue le $_activeBookedDate pour le créneau $_activeBookedSlot. Merci !",
                        style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text("Annuler ma venue"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: _cancelIntention,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 48),
            ] else ...[
              const Text(
                "A quelle heure prévoyez-vous de venir ?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: slots.map((slot) {
                  return ChoiceChip(
                    label: Text(slot, style: const TextStyle(fontSize: 20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    selected: _selectedSlot == slot,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSlot = selected ? slot : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                ),
                onPressed: (_selectedSlot == null || _isSubmitting) 
                    ? null 
                    : () => _submitIntention(targetDate, targetDateStr),
                child: _isSubmitting 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3)) 
                    : const Text("Valider mon intention", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 48),
            ],
            
            if (slots.isNotEmpty) ...[
              const Text(
                "Intentions cumulées pour cette journée",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Intention>>(
                  initialData: const [],
                  stream: widget.db.subscribeToIntentions(widget.locationId, targetDateStr),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final intentions = snapshot.data ?? [];
                    
                    final Map<String, int> counts = {};
                    for (var slot in slots) {
                      counts[slot] = 0;
                    }
                    for (var i in intentions) {
                      if (counts.containsKey(i.timeSlot)) {
                        counts[i.timeSlot] = counts[i.timeSlot]! + 1;
                      }
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: slots.length,
                      itemBuilder: (context, index) {
                        final slot = slots[index];
                        final count = counts[slot]!;
                        return ListTile(
                          title: Text(slot, style: const TextStyle(fontSize: 20)),
                          trailing: CircleAvatar(
                            radius: 20,
                            child: Text(count.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    );
                  },
                ),
            ]
          ],
        ),
      ),
      ),
    );
  }
}
