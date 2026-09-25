import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';
import '../models/intention.dart';
import '../models/daily_status.dart';

abstract class DatabaseService {
  Stream<Report?> subscribeToLatestReport(String locationId);
  Stream<List<Intention>> subscribeToIntentions(String locationId, String targetDate);
  Stream<DailyStatus?> subscribeToDailyStatus(String locationId, String targetDate);

  Future<void> addReport(Report report);
  Future<void> addIntention(Intention intention);
  Future<void> updateDailyStatus(String locationId, DailyStatus status);
}

class FirestoreDatabaseService implements DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<DailyStatus?> subscribeToDailyStatus(String locationId, String targetDate) {
    return _firestore
        .collection('daily_status')
        .doc('$locationId-$targetDate')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return DailyStatus.fromJson(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  @override
  Stream<List<Intention>> subscribeToIntentions(String locationId, String targetDate) {
    return _firestore
        .collection('intentions')
        .where('location_id', isEqualTo: locationId)
        .where('target_date', isEqualTo: targetDate)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Intention.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Stream<Report?> subscribeToLatestReport(String locationId) {
    return _firestore
        .collection('reports')
        .where('location_id', isEqualTo: locationId)
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return Report.fromJson(doc.data(), doc.id);
      }
      return null;
    });
  }

  @override
  Future<void> addIntention(Intention intention) async {
    await _firestore.collection('intentions').doc(intention.id).set(intention.toJson());
  }

  @override
  Future<void> addReport(Report report) async {
    await _firestore.collection('reports').doc(report.id).set(report.toJson());
  }

  @override
  Future<void> updateDailyStatus(String locationId, DailyStatus status) async {
    await _firestore
        .collection('daily_status')
        .doc('$locationId-${status.date}')
        .set(status.toJson());
  }
}

class InMemoryDatabaseService implements DatabaseService {
  final List<Report> _reports = [];
  final List<Intention> _intentions = [];
  final Map<String, DailyStatus> _dailyStatuses = {};

  final _reportsController = StreamController<Report?>.broadcast();
  final _intentionsController = StreamController<List<Intention>>.broadcast();
  final _dailyStatusController = StreamController<DailyStatus?>.broadcast();

  InMemoryDatabaseService() {
    _reportsController.add(null);
    _intentionsController.add([]);
    _dailyStatusController.add(null);
  }

  @override
  Stream<DailyStatus?> subscribeToDailyStatus(String locationId, String targetDate) async* {
    yield _dailyStatuses['$locationId-$targetDate'];
    yield* _dailyStatusController.stream;
  }

  @override
  Stream<List<Intention>> subscribeToIntentions(String locationId, String targetDate) async* {
    yield _intentions.where((i) => i.locationId == locationId && i.targetDate == targetDate).toList();
    yield* _intentionsController.stream;
  }

  @override
  Stream<Report?> subscribeToLatestReport(String locationId) async* {
    try {
      final latest = _reports.firstWhere((r) => r.locationId == locationId);
      yield latest;
    } catch (e) {
      yield null;
    }
    yield* _reportsController.stream;
  }

  @override
  Future<void> addIntention(Intention intention) async {
    _intentions.add(intention);
    _intentionsController.add(
      _intentions.where((i) => i.locationId == intention.locationId && i.targetDate == intention.targetDate).toList()
    );
  }

  @override
  Future<void> addReport(Report report) async {
    _reports.add(report);
    _reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    try {
      final latest = _reports.firstWhere((r) => r.locationId == report.locationId);
      _reportsController.add(latest);
    } catch (e) {
      // Ignore
    }
  }

  @override
  Future<void> updateDailyStatus(String locationId, DailyStatus status) async {
    _dailyStatuses['$locationId-${status.date}'] = status;
    _dailyStatusController.add(status);
  }
}
