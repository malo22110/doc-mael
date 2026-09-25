import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:affluence_app/main.dart';
import 'package:affluence_app/services/database.dart';
import 'package:affluence_app/utils/time_utils.dart';

void main() {
  group('E2E App Flow', () {
    testWidgets('[SPEC-F01] [SPEC-F05] Verify HomeView renders and can navigate to DeclareView with accessible UI', (tester) async {
      
      // Override database with Mock for testing
      databaseService = InMemoryDatabaseService();
      
      // Build the app
      await tester.pumpWidget(const AffluenceApp());
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final bool isOpen = TimeUtils.isOpen(now);

      if (isOpen) {
        // Cabinet is OPEN
        expect(find.text("Affluence en salle d'attente"), findsOneWidget);

        final arriveButton = find.text("Je suis arrivé dans la salle d'attente");
        expect(arriveButton, findsOneWidget);
        
        await tester.tap(arriveButton);
        await tester.pumpAndSettle();

        expect(find.text("Combien de personnes patientent en salle d'attente ?"), findsOneWidget);

        final zeroTwoButton = find.text("0 - 2 personnes");
        expect(zeroTwoButton, findsOneWidget);
        await tester.tap(zeroTwoButton);
        await tester.pumpAndSettle();

        expect(find.text("Merci pour votre signalement !"), findsOneWidget);
        
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(find.text("Affluence en salle d'attente"), findsOneWidget);
      } else {
        // Cabinet is CLOSED
        expect(find.text("Le cabinet est actuellement fermé."), findsOneWidget);
      }
    });
  });
}
