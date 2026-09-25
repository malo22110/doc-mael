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
    'Goéland',
    'Andouille',
    'Artichaut',
    'Cidre',
    'Ciré',
    'Chouchen',
    'Crêpe',
    'Bigoudène'
  ];

  static final List<String> _suffixes = [
    'Salé',
    'Beurré',
    'Saucisse',
    'Fruité',
    'Breton',
    'Têtu',
    'Rôti',
    'Doré',
    'EnBottes',
    'Farci',
    'Moelleux',
    'Jaune',
    'Tempête',
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
