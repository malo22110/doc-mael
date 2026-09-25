import 'package:flutter/material.dart';

class DocMaelIcon extends StatelessWidget {
  final double size;

  const DocMaelIcon({super.key, this.size = 64.0});

  static const Color tealColor = Color(0xFF1D829B);
  static const Color orangeColor = Color(0xFFD4542E);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.04),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.75,
          height: size * 0.75,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cadran / Jauge circulaire
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: 0.78,
                  strokeWidth: size * 0.06,
                  strokeCap: StrokeCap.round,
                  valueColor: const AlwaysStoppedAnimation<Color>(tealColor),
                  backgroundColor: Colors.transparent,
                ),
              ),
              // Croix médicale
              Icon(Icons.add_rounded, color: tealColor, size: size * 0.55),
              // Point central d'ancrage de l'aiguille
              Container(
                width: size * 0.14,
                height: size * 0.14,
                decoration: const BoxDecoration(
                  color: orangeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
