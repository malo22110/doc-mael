import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affluence_app/services/database.dart';
import 'package:affluence_app/views/intentions_view.dart';
import 'package:affluence_app/utils/time_utils.dart';

void main() {
  group('IntentionsView Tests', () {
    testWidgets('[SPEC-F03] User can declare an intention and it prevents double-booking', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final db = InMemoryDatabaseService();
      
      await tester.pumpWidget(MaterialApp(
        home: IntentionsView(db: db),
      ));
      await tester.pumpAndSettle();

      // Check if we are on the intentions page
      expect(find.text("Intentions cumulées pour cette journée"), findsOneWidget);

      // Find an available slot and tap it
      // Since time depends on when the test runs, we just find the first ChoiceChip
      final firstSlot = find.byType(ChoiceChip).first;
      expect(firstSlot, findsOneWidget);
      
      await tester.tap(firstSlot);
      await tester.pumpAndSettle();

      // Tap the validation button
      final validateButton = find.text("Valider mon intention");
      await tester.ensureVisible(validateButton);
      await tester.tap(validateButton);
      await tester.pumpAndSettle();

      // It should now show the confirmation message because of the active intention
      expect(find.textContaining("Vous avez déjà signalé votre venue"), findsOneWidget);
      
      // The slot buttons should be hidden
      expect(find.byType(ChoiceChip), findsNothing);
    });
  });
}
