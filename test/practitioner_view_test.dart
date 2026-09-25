import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:affluence_app/services/database.dart';
import 'package:affluence_app/views/practitioner_view.dart';

void main() {
  group('PractitionerView Tests', () {
    testWidgets('[SPEC-F02] User can declare the number of active practitioners', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final db = InMemoryDatabaseService();
      
      await tester.pumpWidget(MaterialApp(
        home: PractitionerView(db: db),
      ));
      await tester.pumpAndSettle();

      // Find the title
      expect(find.text("Combien de médecins consultent actuellement ?"), findsOneWidget);

      // Find the buttons for 1, 2, 3, 4
      expect(find.text("1"), findsOneWidget);
      expect(find.text("2"), findsOneWidget);
      expect(find.text("3"), findsOneWidget);
      expect(find.text("4"), findsOneWidget);

      // Tap on "3"
      await tester.tap(find.text("3"));
      await tester.pumpAndSettle();

      // Check if snackbar appeared
      expect(find.text("Statut mis à jour : 3 médecin(s)"), findsOneWidget);
    });
  });
}
