import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos & Mentions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('📌 À propos de Doc\'Mael'),
            _buildParagraph(
              "Doc'Mael est une initiative citoyenne et collaborative (similaire au fonctionnement de Waze). "
              "Son but est de permettre aux patients du Cabinet Médical de Maël-Carhaix de s'entraider en partageant l'affluence en salle d'attente.",
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('⚠️ Avertissement et Responsabilité'),
            _buildParagraph(
              "Les informations affichées sur cette application sont fournies EXCLUSIVEMENT par les patients présents sur place. "
              "Elles sont données à titre purement indicatif et ne garantissent en rien le temps d'attente réel.",
            ),
            _buildParagraph(
              "L'application Doc'Mael N'EST PAS gérée par les médecins ni par le secrétariat du cabinet médical. "
              "Par conséquent, le cabinet médical de Maël-Carhaix et les créateurs de cette application déclinent toute responsabilité "
              "quant à l'exactitude des données affichées ou aux éventuels désagréments liés à votre temps d'attente.",
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('🔒 Anonymat & Données Privées'),
            _buildParagraph(
              "Le respect de la vie privée est au cœur de l'application :\n\n"
              "• Aucun compte ni mot de passe n'est requis.\n"
              "• Aucune donnée médicale n'est demandée ou traitée.\n"
              "• Votre identité est protégée par un pseudonyme breton généré aléatoirement (ex: CrêpeDoré) afin que vous ne soyez jamais considéré comme un simple numéro de ticket.\n"
              "• L'application ne conserve aucun historique personnel.",
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('💡 Comment ça marche ?'),
            _buildParagraph(
              "Une simple affiche avec un QR Code est disponible en salle d'attente. Lorsqu'un patient arrive, il scanne le code et indique, en un clic, combien de personnes patientent déjà. "
              "Cette information est alors immédiatement partagée à toute la communauté pour aider les prochains arrivants à anticiper leur venue.",
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Fait avec ❤️ pour Maël-Carhaix",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D829B),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}
