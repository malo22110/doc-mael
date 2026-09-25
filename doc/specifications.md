# Cahier des Charges - Affluence App

## 1. Vision Générale
Application de suivi de l'affluence en salle d'attente d'un cabinet médical, fonctionnant sur un modèle collaboratif de type "Waze". Les patients déclarent le volume de la salle d'attente lors de leur arrivée.

**Important** : Ce n'est **PAS** un système de file d'attente numérique (pas de ticket virtuel). L'ordre de passage reste géré par la secrétaire ou l'ordre d'arrivée physique.

## 2. Fonctionnalités Principales (Spécifications Fonctionnelles)

### SPEC-F01 : Mode collaboratif (Déclaration d'affluence)
- L'utilisateur peut déclarer le niveau d'affluence via 4 tranches : `0-2`, `3-5`, `6-9`, `10+` personnes.
- L'accès à la déclaration se fait soit par QR code (dans le cabinet), soit via un bouton "Je suis arrivé dans la salle d'attente".
- La dernière tranche déclarée est affichée publiquement avec un horodatage.

### SPEC-F02 : Nombre de praticiens
- L'utilisateur (ou le praticien) peut déclarer le nombre de médecins actuellement en consultation (1, 2, 3 ou 4).
- Cette information est visible sur l'écran d'accueil pour aider à estimer la vitesse d'écoulement de la salle.

### SPEC-F03 : Intentions de passage
- L'utilisateur peut déclarer qu'il a l'intention de venir à un créneau horaire donné.
- Seuls les créneaux futurs de la journée en cours (ou de la prochaine journée d'ouverture) sont sélectionnables.
- Sécurité anti-spam : Une seule réservation active à la fois par utilisateur (bloqué via le stockage local) jusqu'à ce que l'heure du créneau soit passée.
- L'utilisateur a la possibilité d'**annuler son intention de venue** à tout moment via un bouton dédié, ce qui supprime sa prévision de la base de données.

### SPEC-F04 : Gestion des horaires d'ouverture
- Le cabinet est ouvert :
  - Du Lundi au Vendredi : 08:00 à 18:30.
  - Le Samedi : 08:00 à 12:00.
  - Le Dimanche : Fermé.
- En dehors des horaires d'ouverture, l'application affiche "Le cabinet est actuellement fermé".
- Lorsque le cabinet est fermé, l'écran d'accueil affiche un résumé des intentions de passage (affluence prévue) pour le prochain jour d'ouverture.

### SPEC-F05 : Interface Senior-Friendly
- Focus absolu sur l'accessibilité pour les personnes âgées :
  - Textes de très grande taille.
  - Boutons larges avec des zones de clic permissives.
  - Couleurs contrastées (vert, orange, rouge).
  - Retours visuels clairs (Bandeau de confirmation "Merci pour votre signalement").

## 3. Contraintes Techniques (Spécifications Techniques)

### SPEC-T01 : Anonymat et Identification
- **Anonymat Absolu** : Aucune donnée personnelle (nom, prénom, email, téléphone) n'est demandée ou stockée en base de données.
- Un pseudo aléatoire convivial à connotation bretonne (ex: `KouignSalé`, `GaletteSaucisse`, `MenhirEnBottes`) est généré localement lors de la première ouverture de l'application et stocké dans les `SharedPreferences`. Il permet d'éviter que les patients ne confondent un numéro de "Patient_1234" avec un numéro de file d'attente (ticket).

### SPEC-T02 : Base de données
- Firebase Firestore est utilisé comme backend de production.
- Les données remontées sont : `reports` (affluence), `intentions`, et `daily_status` (médecins).
- Firebase Hosting héberge la version Web.

### SPEC-T03 : CI/CD
- GitHub Actions est configuré pour compiler automatiquement l'application Flutter Web (`flutter build web`) et la déployer sur Firebase Hosting à chaque *push* sur la branche `master`.

## 4. Matériel Physique (Salle d'attente)
- **Affiche A4** : Une [affiche imprimable (HTML)](affiche.html) est fournie dans le dossier de documentation. Elle présente le QR Code de l'application, les 3 étapes d'utilisation, et garantit aux patients l'anonymat de leur participation.
