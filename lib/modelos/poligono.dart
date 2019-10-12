import 'punto.dart';

class Poligono {
  List<Punto> puntos;
  bool tipo;

//
  Poligono() {
    puntos = new List();
    tipo=true;
  }
  

  // Poligono.insertar(Punto p) {
  //   poligono = new List();
  //   poligono.add(p);
  // }

  void setTipo(bool value) => tipo = value;

  bool get getTipo =>tipo;

  void insertarPunto(Punto p) => puntos.add(p);
//Funcion para obtener Punto en el caso de poligono cerrado
  Punto getPrimerPunto()=>puntos[0];

}
