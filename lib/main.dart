import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'models/daily_status.dart';
import 'services/database.dart';
import 'views/home_view.dart';
import 'views/declare_view.dart';
import 'views/intentions_view.dart';
import 'views/practitioner_view.dart';
import 'views/about_view.dart';
import 'theme/app_theme.dart';

// Provide a mock service by default unless Firebase is configured.
DatabaseService databaseService = InMemoryDatabaseService();
FirebaseAnalytics? analytics;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force Firestore to ensure we are actually using it
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  databaseService = FirestoreDatabaseService();
  analytics = FirebaseAnalytics.instance;
  print('Firebase initialized. Using Firestore and Analytics.');
  
  runApp(AffluenceApp(
    router: GoRouter(
      initialLocation: '/',
      observers: [FirebaseAnalyticsObserver(analytics: analytics!)],
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
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutView(),
        ),
      ],
    ),
  ));
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

class AffluenceApp extends StatelessWidget {
  final GoRouter? router;
  const AffluenceApp({super.key, this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Doc'Mael",
      theme: DocMaelTheme.lightTheme,
      routerConfig: router ?? GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, __) => HomeView(db: databaseService)),
          GoRoute(path: '/presence', builder: (_, state) => DeclareView(db: databaseService, locationId: state.uri.queryParameters['loc'] ?? 'mael_carhaix')),
          GoRoute(path: '/intentions', builder: (_, __) => IntentionsView(db: databaseService)),
          GoRoute(path: '/practitioner', builder: (_, __) => PractitionerView(db: databaseService)),
          GoRoute(path: '/about', builder: (_, __) => const AboutView()),
        ]
      ),
    );
  }
}
