abstract class Coordenadas {
  double get eixoX;
  double get eixoY;
}

class ModeloCoordenadas implements Coordenadas {
  final double eixoX;
  final double eixoY;

  ModeloCoordenadas({required this.eixoX, required this.eixoY});
}
