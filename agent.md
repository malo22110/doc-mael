# Règles de Conduite de l'Agent IA (Agent Rules)

En tant qu'assistant IA travaillant sur ce projet, tu DOIS respecter scrupuleusement les règles suivantes à chaque itération ou modification de code :

## 1. Qualité et Accessibilité (Focus "Personnes Âgées")
- **Tailles de police :** L'interface doit être lisible pour un public senior. Utilise toujours des tailles de polices généreuses (`fontSize` minimum de 18-20 pour le texte courant, 24-32 pour les appels à l'action).
- **Boutons :** Les zones de clics (touch targets) doivent être très larges (utiliser de gros `Padding` ou `SizedBox`).
- **Contraste :** Utilise des couleurs vives et contrastées (vert, orange, rouge) avec des textes très lisibles.
- **Clarté :** Pas de jargon technique dans l'UI. Les messages d'erreur et de succès doivent être rassurants et compréhensibles.

## 2. Documentation Vivante (Obligatoire)
- **Mise à jour immédiate :** Si tu ajoutes, modifies ou supprimes une fonctionnalité (Feature), tu DOIS immédiatement ouvrir le fichier `doc/specifications.md` et le mettre à jour.
- La documentation est la source de vérité. Le code ne doit jamais diverger des spécifications écrites.

## 3. Tests (TU & E2E)
- **Tests Unitaires (TU) :** Toute nouvelle logique métier (ex: horaires, filtres, tris) doit être accompagnée d'un Test Unitaire dans le dossier `test/`.
- **Tests End-to-End (E2E) :** Tout flux utilisateur important doit être couvert dans `integration_test/`.
- **Traçabilité :** Les descriptions des tests E2E et TU doivent explicitement faire référence au numéro de spécification concerné présent dans `doc/specifications.md` (exemple : `testWidgets('[SPEC-F01] Verify crowd reporting flow', ...)`).

## 4. Anonymat et Modèle de Données
- Ne propose JAMAIS d'ajouter un système de compte utilisateur nominatif, de login par email, ou de file d'attente numérique avec des identifiants patients nominatifs.
- Reste strictement sur le modèle "Waze" (déclaratif et anonyme basé sur l'appareil/SharedPreferences).
