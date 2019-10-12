import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plottertopicos/modelos/punto.dart';
import 'package:plottertopicos/modelos/Escenario.dart';
import 'dart:ui' as ui;

class Dibujo extends CustomPainter {
  //Necesario para dibujar
  Escenario escenario;
  Punto puntoInicial;
  Punto puntoFinal;
  bool asignarPrimerPunto;
  
  Dibujo(this.escenario,this.asignarPrimerPunto);

  @override
  bool shouldRepaint(Dibujo old) {
    return true;
  }
  void paint(Canvas canvas, Size size) {

    final pointMode = ui.PointMode.points;
    //recorrido de objetos class Escenario
    this.escenario.objetos.forEach((objeto) {
      final pincel = Paint()//
      //..color = objeto.color//Solo demostracion
      ..color = Color.fromARGB(objeto.color[0], objeto.color[1],objeto.color[2], objeto.color[3])
      ..strokeWidth = 4;//
      //recorrido de poligonos class Objeto
      objeto.poligonos.forEach((poligono) {
        //recorrido de puntos class Poligono
        poligono.puntos.forEach((punto) {
          if (!this.asignarPrimerPunto) {
            this.puntoFinal=this.convertirAbsoluto(punto, size);
            //this.puntoFinal=punto;
            canvas.drawLine(
                Offset(this.puntoInicial.getX, this.puntoInicial.getY),
                Offset(this.puntoFinal.getX, this.puntoFinal.getY),
                pincel);
            this.puntoInicial = this.puntoFinal;
            //this.puntoInicial = this.puntoFinal;
          } else {
            Punto p1 = convertirAbsoluto(punto, size);
          canvas.drawPoints(pointMode, [Offset(p1.getX,
                 p1.getY)], pincel);
            this.puntoInicial = this.convertirAbsoluto(punto, size);
           // this.puntoInicial=punto;
            this.asignarPrimerPunto = false;
          }
        });
        this.asignarPrimerPunto = true;
        //Caso poligono cerrado o abierto
        if (!poligono.getTipo) {
          Punto punto=this.convertirAbsoluto(poligono.getPrimerPunto(), size);
          canvas.drawLine(
              Offset(punto.getX,punto.getY),
              Offset(this.puntoInicial.getX, this.puntoInicial.getY),
              pincel);
        }
      });
    });
  }

  Punto convertirAbsoluto(Punto punto,Size size){
    double width=size.width/2;
    double height=size.height/2;
    double x=punto.getX+width;
    double y=punto.getY-height;
    return new Punto(x, (-1*y));
  }

 
}
