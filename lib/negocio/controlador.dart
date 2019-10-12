import 'package:plottertopicos/modelos/poligono.dart';

import 'package:plottertopicos/modelos/Escenario.dart';
import 'package:plottertopicos/modelos/objeto.dart';
import 'package:plottertopicos/modelos/punto.dart';

class Controlador{
  Escenario escenario;
  Objeto objeto;
  Poligono poligono;
  bool asignarPrimerPunto;
  double width;
  double height;

  Controlador() {
    escenario = new Escenario();
    objeto = new Objeto();
    poligono = new Poligono();
    asignarPrimerPunto = true;
    iniciarArea();
  }
   void iniciarArea() {
    this.objeto.insertarPoligono(this.poligono);
    this.escenario.insertarobjeto(this.objeto);
  }
  void nuevoPoligono(){
    Poligono p = new Poligono();
    this.objeto.poligonos.add(p);
    this.poligono=p;
  }

    void nuevoObjeto(){
    Poligono newPoligono = new Poligono();
    this.poligono=newPoligono;
    Objeto newObjeto=new Objeto();
    newObjeto.poligonos.add(newPoligono);
    this.objeto=newObjeto;
    this.escenario.objetos.add(newObjeto);
  }

  void cerrarPoligono(){
    poligono.setTipo(false);
  }

  void insertarPunto(double x,double y){
    print('original ');
    print(y);


    x=conversionRelativaX(x);
    y=conversionRelativaY(y);
     print('relativas ');
    print(y);
    this.poligono.puntos.add(new Punto(x,y));
  }

  double conversionRelativaY(double valor){
  
    return this.height-valor;
  }

  double conversionRelativaX(double valor){
      calcularOrigen();
    return valor-this.width;
  }

  void calcularOrigen(){
    this.width=this.width/2;
    this.height=this.height/2;
  }
  limpiarArea(){
    escenario = new Escenario();
    objeto = new Objeto();
    poligono = new Poligono();
    asignarPrimerPunto = true;
    iniciarArea();
  }
  
  eliminarLastPunto(){
    this.poligono.puntos.removeLast();
  }
  String dataBluetooth() {
    String data="";
      data="SOH"+","+(this.width*2).round().toString()+","+(this.height*2).round().toString()+","+"EOT"+",";
      bool inicio=true;//Utilizado para el inicio de cada etapa
      data=data+"STX";
      for(int i =0;i<this.escenario.objetos.length;i++){
        Objeto auxObj = this.escenario.objetos[i];
        for(int j=0;j<auxObj.poligonos.length;j++){
          Poligono auxPol =auxObj.poligonos[j];  
        data=data+","+"LF,";
          for(int k=0; k<auxPol.puntos.length;k++){
         Punto auxPunto=this.convertirAbsoluto( auxPol.puntos[k]);
          data=(inicio)?data+ auxPunto.getX.round().toString()+","+ auxPunto.getY.round().toString()
                       :data=data+","+ auxPunto.getX.round().toString()+","+ auxPunto.getY.round().toString();
          inicio=false;//
          }
          inicio=true;
        if (!auxPol.getTipo) {
          data=data+","+this.convertirAbsoluto(auxPol.getPrimerPunto()).getX.round().toString()+","+
                        this.convertirAbsoluto(auxPol.getPrimerPunto()).getY.round().toString();
        }
        data=data+",EOL";
        }
         data=data+",ETB";
      }
      data=data+",ETX"+",EOF";
      
      
      //recorrido de objetos class Escenario
    //   this.escenario.objetos.forEach((objeto) {

    //   //recorrido de poligonos class Objeto
    //   data=(inicio)?data+"[":data=data+","+"[";
    //   this.objeto.poligonos.forEach((poligono) {
    //     //recorrido de puntos class Poligono
    //     data=(inicio)?data+"{":data=data+","+"{";
    //     this.poligono.puntos.forEach((punto) {
    //       punto=this.convertirAbsoluto(punto);
    //       data=(inicio)?data+punto.getX.toString()+","+punto.getY.toString()
    //                    :data=data+","+punto.getX.toString()+","+punto.getY.toString();
    //       inicio=false;//corto los inicios
    //     });
    //     //Caso poligono cerrado
    //     if (!poligono.getTipo) {
    //       data=data+","+poligono.getPrimerPunto().getX.toString()+","+
    //                     poligono.getPrimerPunto().getY.toString();
    //     }
    //     data=data+"}";
    //   });
    //   data=data+"]";
    // });
    print(data);
    return data;
  }

  Punto convertirAbsoluto(Punto punto){
    double x=punto.getX+width;
    double y=punto.getY-height;
    return new Punto(x, (-1*y));
  }
   
}

