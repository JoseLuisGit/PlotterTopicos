import 'dart:math';

import 'package:plottertopicos/modelos/Inside.dart';
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
  List<Poligono>marcado;//Para la seleccion

  Controlador() {
    escenario = new Escenario();
    objeto = new Objeto();
    poligono = new Poligono();
    asignarPrimerPunto = true;
    marcado=new List<Poligono>();
    iniciarArea();
  }
  //Usado al abrir un archivo guardado
  void restablecerArea(){
    this.objeto=this.escenario.getObjetoBase();
    this.poligono=this.objeto.getLastPoligono();
  }

  void iniciarArea() {
    this.objeto.insertarPoligono(this.poligono);
    this.escenario.insertarobjeto(this.objeto);
  }

  void nuevoPoligono(){
    Poligono p = new Poligono();
    this.objeto.insertarPoligono(p);
    this.poligono=p;
  }

  void cerrarPoligono(){
    poligono.setTipo(false);
  }

  void insertarPunto(double x,double y){
    //print('original ');
    //print(x);
    //print(y);
    x=conversionRelativaX(x);
    y=conversionRelativaY(y);
    print('relativas ');
    print(x);
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

  Punto convertirAbsoluto(Punto punto){
    double x=punto.getX+width/2;
    double y=punto.getY-height/2;
    return new Punto(x, (-1*y));
  }

  limpiarArea(){
    escenario = new Escenario();
    objeto = new Objeto();
    poligono = new Poligono();
    asignarPrimerPunto = true;
    iniciarArea();
    this.marcado.clear();//Limpiando los seleccionados
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
    print(data);
    return data;
  }
  
  //PRUEBAS
  void selectPoligono(double x,double y){
    x=conversionRelativaX(x);
    y=conversionRelativaY(y);
    print("$x , $y");
    for(int i=0;i<this.escenario.objetos.length;i++){
        for(int j=this.escenario.objetos[i].poligonos.length-2;j>=0;j--){//-2 para evitar el nuevo poligono creado
          bool prueba=PointLocal().pointInPolygon(Punto(x,y), this.escenario.objetos[i].poligonos[j]);
          print(prueba);
          if(prueba){
            if(i==0){//0 es el this.escenario.objetos[i] principal
              if(this.marcado!=null&&this.marcado.contains(this.escenario.objetos[i].poligonos[j])){
                this.marcado.remove(this.escenario.objetos[i].poligonos[j]);//elimino de la lista
              }else{
                this.marcado.add(this.escenario.objetos[i].poligonos[j]);//añadiendo
              }
              if(this.marcado.length==1){//Si es un poligono para aplicar edicion
                this.poligono=this.marcado[0];//selecciono el unico que queda
              }else{//Mas de uno vuelvo a la normalidad
                this.poligono=this.escenario.objetos[i].getLastPoligono();
              }
              return;
            }else{//Si el objeto es diferente al object 0
              if(this.marcado!=null&&this.marcado.contains(this.escenario.objetos[i].poligonos[j])){
                this.objeto=this.escenario.objetos[i];
                deseleccionarObjeto();
                this.objeto=this.escenario.objetos[0];//vuelvo a establecer en el objeto 0 para continuar los dibujos
              }else{
                this.objeto=this.escenario.objetos[i];//Igualo al objeto seleccionado para modificar
                marcarTodoObject();//envia a la lista de marcados todos los poligonos del object
              }
                this.poligono=this.objeto.getLastPoligono();//Establezco el poligono vacio creado por defecto
              return;
            }
          }
      }
    }
  }

  //Cambiar color a los seleccionados
  cambiarColor(int color){
    for(int i=0;i<this.marcado.length;i++){
      this.marcado[i].setColor(color);
    }
  }

  //Coloco todos los poligonos del objeto seleccionado en los marcados
  marcarTodoObject(){
    for(int i=0;i<this.objeto.getLengthPoligonos()-1;i++){//-1 para no añadir el poligono vacio
      this.marcado.add(this.objeto.getPoligono(i));
    }
  }

  //Deselecciono el objeto sin afectar los otros seleccionados
  deseleccionarObjeto(){
    //int length=this.objeto.poligonos.length-1;//no invluye el poligono vacio
    for(int i=0;i<this.marcado.length;i++){
      if(this.objeto.existePoligono(this.marcado[i])){
        //this.marcado.removeRange(i, i+length);//Encuentra y elimina la longitud de la lista poligonos
        //return;
        this.marcado.removeAt(i);
        i--;
      }
    }
  }
  
  //Elimino el ultimo punto del poligono seleccionado
  eliminarLastPunto(){
    this.poligono.eliminarLastPunto();
  }

  //Elimino el punto Selecionado
  eliminarPuntoSelect(double x,double y){
    for(int i=0;i<this.poligono.getLengthPuntos();i++){
      if(estaRango(this.convertirAbsoluto(this.poligono.getPunto(i)),Punto(x,y))){
        this.poligono.eliminarPunto(i);//.puntos.removeAt(i);
        if(this.poligono.getLengthPuntos()==0){
          this.objeto.eliminarPoligono(this.poligono);//poligonos.remove(this.poligono);
          this.poligono=this.objeto.getLastPoligono();
        }
        return;
      }
    }
  }

  bool estaRango(Punto a,Punto b){
    print("(${a.getX} ${b.getX}) (${a.getY} ${b.getY})");
    double rango=sqrt((pow((b.getX-a.getX),2))+(pow((b.getY-a.getY),2)));
    return (rango.abs()>=0 && rango.abs()<=15);
  }

  //Elimino los seleccionado
  eliminarSeleccionados(){
    //Eliminando objetos seleccionados
    if(this.escenario.getLengthObjetos()>1){
      this.eliminarObjeSelect();
    }
    //Eliminando poligonos normales
    if(this.marcado.length>0){
      this.eliminarPoligSelect();
    }
    this.poligono=this.objeto.getLastPoligono();//Apuntamos al poligono vacio
  }
  //Elimina objetos seleccionados
  eliminarObjeSelect(){
    for(int i=1;i<this.escenario.getLengthObjetos();i++){//1 porque 0 es la base
      for(int j=0;j<this.marcado.length;j++){
        if(this.escenario.getObjeto(i).existePoligono(this.marcado[j])){//objetos[i].poligonos.contains(this.marcado[j])){
          int length=this.escenario.getObjeto(i).getLengthPoligonos()-1;//.objetos[i].poligonos.length-1;//-1 para no inclui el polino vacio
          this.marcado.removeRange(j, j+length);//Encuentra y elimina la longitud de la lista poligonos
          this.escenario.eliminarObjeto(i);//.objetos.removeAt(i);
          i--;
          break;
        }
      }
    }
    this.objeto=this.escenario.getObjetoBase();//.objetos[0];
  }
  //Elimina poligonos seleccionados
  eliminarPoligSelect(){
    for(int i=0;i<this.marcado.length;i++){
      this.objeto.eliminarPoligono(this.marcado[i]);//.poligonos.remove(this.marcado[i]);//Eliminamos del objeto los poligonos seleccionados
      this.marcado.removeAt(i);
      i--;
    }
  }

  //Crear nuevo objeto de los poligonos seleccionados
  void crearObjeto(String nombre){
    Objeto newObjeto=new Objeto();
    newObjeto.setNombre(nombre);
    newObjeto.setTipo(true);//objeto nuevo

    eliminarPoligonos(newObjeto);//Elimino los pologinos del objeto 0 e inserto al nuevo objecto
    
    newObjeto.insertarPoligonoAux();// .poligonos.add(new Poligono());//Colocando un poligono vacio para continuar dibujo en el objeto seleccionado
    
    this.escenario.insertarobjeto(newObjeto);//.objetos.add(newObjeto);
    this.objeto=newObjeto;//Igualando el objeto con el nuevo creado para la edicion
    this.poligono=this.objeto.getLastPoligono();
  }

  //Eliminar los poligonos seleccionados del objeto 0
  eliminarPoligonos(Objeto objetoAux){
    for(int i=0;i<this.marcado.length;i++){
      if(this.objeto.existePoligono(this.marcado[i])){//.poligonos.contains(this.marcado[i])){
        objetoAux.insertarPoligono(this.marcado[i]);//.poligonos.add(this.marcado[i]);//Añado el poligono que esta seleccionado
        this.objeto.eliminarPoligono(this.marcado[i]);//.poligonos.remove(this.marcado[i]);//eliminacion
      }
    }
  }

  //Elimino el objeto creado(!=0) y sus poligonos se insertan en el objeto 0
  disolverObjeto(){
    //this.eliminarPoligonoVacio();
    this.escenario.getObjetoBase().eliminarPoligonoAux();
    for(int i=0;i<this.marcado.length;i++){
      this.escenario.getObjetoBase().insertarPoligono(this.marcado[i]);//.objetos[0].poligonos.add(this.marcado[i]);//inserto los poligonos del objeto a remover
    }
    this.escenario.eliminarObjetoValue(this.objeto);//.objetos.remove(this.objeto);//elimino el objeto seleccionado 
    this.objeto=this.escenario.getObjetoBase();//.objetos[0];//vuelvo a establecer en el objeto 0 para continuar los dibujos
    this.objeto.insertarPoligonoAux();
    //this.addPoligonoVacio();
  }

  //Permite unir fusionar el objeto con otros poligonos
  fusionarObjeto(){
    //this.eliminarPoligonoVacio();
    this.objeto.eliminarPoligonoAux();
    for(int i=0;i<this.marcado.length;i++){
      if(!this.objeto.existePoligono(this.marcado[i])){//.poligonos.contains(this.marcado[i])){//Si no contiene al poligono lo inserta al objeto
        this.objeto.insertarPoligono(this.marcado[i]);//.poligonos.add(this.marcado[i]);
        this.escenario.getObjetoBase().eliminarPoligono(this.marcado[i]);//.objetos[0].poligonos.remove(this.marcado[i]);//elimino el poligono del objeto 0 porque se fusiono al new object
      }
    }
    this.objeto.insertarPoligonoAux();
    //this.addPoligonoVacio();
  }

  eliminarPoligonoVacio(){
    this.objeto.poligonos.removeLast();//elimino el poligono vacio del objeto para adicionar
  }

  addPoligonoVacio(){
    this.objeto.poligonos.add(new Poligono());//adiciono el poligono vacio al objeto para continuar el dibujo
  }
}

