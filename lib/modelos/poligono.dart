import 'punto.dart';

class Poligono {
  List<Punto> puntos;
  bool tipo;
  int color;//solo por demostracion

  Poligono() {
    puntos = new List();
    tipo=true;
    color= 0xff000000;
  }

  void setTipo(bool value) => tipo = value;

  void setColor(int color){
    this.color=color;
  }

  int get getColor =>color;

  bool get getTipo =>tipo;

  void insertarPunto(Punto p) => puntos.add(p);

  //Funcion para obtener Punto en el caso de poligono cerrado
  Punto getPrimerPunto()=>puntos[0];

  void eliminarLastPunto(){
    this.puntos.removeLast();
  }

  int getLengthPuntos(){
    return this.puntos.length;
  }

  Punto getPunto(int index){
    return this.puntos[index];
  }

  void eliminarPunto(int index){
    this.puntos.removeAt(index);
  }

}
