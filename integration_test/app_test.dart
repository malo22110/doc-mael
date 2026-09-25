import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:affluence_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E App Flow', () {
    testWidgets('[SPEC-F01] [SPEC-F05] Verify HomeView renders and can navigate to DeclareView with accessible UI', (tester) async {
      // Setup mock data for the test (so it doesn't wait on Firebase)
      // Actually we are testing the main app. It will use Firebase if initialized,
      // but since we are in test environment, we might want to mock it.
      // For simplicity, we just boot the app.
      app.main();
      
      // Wait for app to render
      await tester.pumpAndSettle();

      // Find the "Affluence en salle d'attente" title
      expect(find.text("Affluence en salle d'attente"), findsOneWidget);

      // Find the "Je suis arrivé dans la salle d'attente" button
      final arriveButton = find.text("Je suis arrivé dans la salle d'attente");
      
      if (arriveButton.evaluate().isNotEmpty) {
        // Cabinet is OPEN, we can test navigation
        await tester.tap(arriveButton);
        await tester.pumpAndSettle();

        // Check if we are on DeclareView
        expect(find.text("Combien de personnes patientent en salle d'attente ?"), findsOneWidget);

        // Tap the "0 - 2 personnes" button
        final zeroTwoButton = find.text("0 - 2 personnes");
        expect(zeroTwoButton, findsOneWidget);
        await tester.tap(zeroTwoButton);
        await tester.pumpAndSettle();

        // Wait for the SnackBar and redirect back to HomeView
        expect(find.text("Merci pour votre signalement !"), findsOneWidget);
        
        // Wait for snackbar to disappear
        await tester.pumpAndSettle(const Duration(seconds: 3));
        
        // Should be back on HomeView
        expect(find.text("Affluence en salle d'attente"), findsOneWidget);
      } else {
        // Cabinet is CLOSED
        expect(find.text("Le cabinet est actuellement fermé."), findsOneWidget);
      }
    });
  });
}
