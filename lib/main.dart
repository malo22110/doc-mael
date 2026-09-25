import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/daily_status.dart';
import 'services/database.dart';
import 'views/home_view.dart';
import 'views/declare_view.dart';
import 'views/intentions_view.dart';
import 'views/practitioner_view.dart';

// Provide a mock service by default unless Firebase is configured.
DatabaseService databaseService = InMemoryDatabaseService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force Firestore to ensure we are actually using it
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  databaseService = FirestoreDatabaseService();
  print('Firebase initialized. Using Firestore.');
  
  runApp(const AffluenceApp());
}

void _seedMockData() {
  // Seed some mock data for the demo
  final now = DateTime.now();
  final targetDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  
  databaseService.updateDailyStatus('mael_carhaix', DailyStatus(
    date: targetDate,
    activeDoctors: 2,
    lastUpdatedBy: 'system',
    updatedAt: now,
  ));
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeView(db: databaseService),
    ),
    GoRoute(
      path: '/presence',
      builder: (context, state) {
        final loc = state.uri.queryParameters['loc'] ?? 'mael_carhaix';
        return DeclareView(db: databaseService, locationId: loc);
      },
    ),
    GoRoute(
      path: '/intentions',
      builder: (context, state) => IntentionsView(db: databaseService),
    ),
    GoRoute(
      path: '/practitioner',
      builder: (context, state) => PractitionerView(db: databaseService),
    ),
  ],
);

class AffluenceApp extends StatelessWidget {
  const AffluenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Affluence Cabinet Médical',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
