import 'dart:math';

class BretonPseudoGenerator {
  static final List<String> _prefixes = [
    'Kouign',
    'Galette',
    'Far',
    'Beurre',
    'Caramel',
    'Kig',
    'Menhir',
    'Korrigan',
    'Goeland',
    'Andouille',
    'Artichaut',
    'Cidre',
    'Cire',
    'Chouchen',
    'Crepe',
    'Bigoudene'
  ];

  static final List<String> _suffixes = [
    'Sale',
    'Beurre',
    'Saucisse',
    'Fruite',
    'Breton',
    'Tetu',
    'Roti',
    'Dore',
    'EnBottes',
    'Farci',
    'Moelleux',
    'Jaune',
    'Tempete',
    'Piquant',
    'Croustillant',
  ];

  static String generate() {
    final rand = Random();
    final p = _prefixes[rand.nextInt(_prefixes.length)];
    final s = _suffixes[rand.nextInt(_suffixes.length)];
    return '$p$s';
  }
}
