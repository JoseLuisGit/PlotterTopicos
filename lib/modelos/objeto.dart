import 'dart:math';

import 'package:plottertopicos/modelos/poligono.dart';
class Objeto{
 List<Poligono> poligonos;
  var color;//solo por demostracion
Objeto(){
  poligonos= new List();
  
  final _random = new Random();
  int next(int min, int max) => min + _random.nextInt(max - min);

 int c1=next(200,255);int c2=next(0,255);int c3=next(0,255);int c4=next(0,255);//solo por demostracion
 color= [c1, c2, c3,c4];
  //color=Color.fromARGB(c1, c2, c3, c4);//Solor por demostracion;
}


void insertarPoligono(Poligono p) => poligonos.add(p);

}