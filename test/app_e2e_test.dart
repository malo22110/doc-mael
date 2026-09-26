import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:affluence_app/main.dart';
import 'package:affluence_app/services/database.dart';
import 'package:affluence_app/utils/time_utils.dart';
import 'package:affluence_app/views/declare_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('E2E App Flow', () {
    testWidgets('[SPEC-F01] [SPEC-F02] [SPEC-F05] Verify full flow and realtime data updates', (tester) async {
      SharedPreferences.setMockInitialValues({});
      databaseService = InMemoryDatabaseService();
      
      TimeUtils.forceOpenForTesting = true;
      DeclareView.bypassLocationForTesting = true;

      await tester.pumpWidget(const AffluenceApp());
      await tester.pumpAndSettle();

      // --- 1. TEST DECLARE CROWDING ---
      final arriveButton = find.text("Je suis arrivé dans la salle d'attente");
      expect(arriveButton, findsOneWidget);
        await tester.tap(arriveButton);
        await tester.pumpAndSettle();

        final zeroTwoButton = find.text("0 - 5 personnes");
        expect(zeroTwoButton, findsOneWidget);
        await tester.tap(zeroTwoButton);
        await tester.pumpAndSettle();

        // Redirected back to HomeView, check if gauge updated
        await tester.pumpAndSettle(const Duration(seconds: 3)); // Wait for snackbar
        expect(find.text("0-5"), findsOneWidget, reason: "Gauge should show the new value");
    });
  });
}
