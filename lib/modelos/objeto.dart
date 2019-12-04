import 'package:plottertopicos/modelos/poligono.dart';

class Objeto{
 List<Poligono> poligonos;
 String nombre;
 bool tipo;
  Objeto(){
    poligonos= new List();
    tipo=false;//es el objeto 0 para almacenar los poligonos
  }

  void setNombre(String nombre){
    this.nombre=nombre;
  }

  String get getNombre =>this.nombre;

  bool get getTipo =>this.tipo;

  void setTipo(bool tipo){//Para los nuevos objetos creados
    this.tipo=tipo;
  }

  void insertarPoligono(Poligono p) => poligonos.add(p);

  Poligono getLastPoligono()=>poligonos[poligonos.length-1];

  int getLengthPoligonos(){
    return this.poligonos.length;
  }

  Poligono getPoligono(int index){
    return this.poligonos[index];
  }

  void eliminarPoligono(Poligono poligono){
    this.poligonos.remove(poligono);
  }

  bool existePoligono(Poligono poligono){
    return this.poligonos.contains(poligono);
  }

  void eliminarPoligonoAux(){
    this.poligonos.removeLast();
  }

  void insertarPoligonoAux(){
    this.poligonos.add(new Poligono());
  }
}