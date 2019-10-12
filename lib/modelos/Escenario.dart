import 'objeto.dart';

class Escenario {
  List<Objeto> objetos;
  Escenario() {
    objetos = new List();
  }

  void insertarobjeto(Objeto o) => objetos.add(o);
}
