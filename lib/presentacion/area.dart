import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plottertopicos/presentacion/Bluetooth.dart' as prefix0;
import 'package:plottertopicos/presentacion/bluetooth.dart';

import 'package:path_provider/path_provider.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:plottertopicos/modelos/punto.dart';
import 'package:plottertopicos/modelos/poligono.dart';
import 'package:plottertopicos/modelos/Escenario.dart';
import 'package:plottertopicos/modelos/objeto.dart';
import 'package:plottertopicos/negocio/controlador.dart';
import 'package:plottertopicos/negocio/dibujador.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';

import 'package:flutter_colorpicker/material_picker.dart';
part 'area.jser.dart';

@GenSerializer()
class PuntoJsonSerializer extends Serializer<Punto> with _$PuntoJsonSerializer {
}

@GenSerializer()
class PoligonoJsonSerializer extends Serializer<Poligono>
    with _$PoligonoJsonSerializer {}

@GenSerializer()
class ObjetoJsonSerializer extends Serializer<Objeto>
    with _$ObjetoJsonSerializer {}

@GenSerializer()
class EscenarioJsonSerializer extends Serializer<Escenario>
    with _$EscenarioJsonSerializer {}

@GenSerializer()
class ControladorJsonSerializer extends Serializer<Controlador>
    with _$ControladorJsonSerializer {}

class AreaPage extends StatefulWidget {
  AreaPage({Key key}) : super(key: key);

  _AreaPageState createState() => _AreaPageState();
}

class _AreaPageState extends State<AreaPage> {
  Controlador c = new Controlador();
  bool select=true;//Para mostrar mensaje de desactivar
  bool selectPunto=true;
  Color currentColor = Colors.amber;//Color inicial
  ControladorJsonSerializer clse = new ControladorJsonSerializer();
  TapPosition _position = TapPosition(Offset.zero, Offset.zero);
  TextEditingController nombreControler = new TextEditingController();
  TextEditingController nombreObjeto = new TextEditingController();
  ///variables de filepicker
  String _fileName;
  String _path;

  String _extension = 'odt';

  FileType _pickingType = FileType.CUSTOM;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    //print(size.width);
    //print(size.height);
    c.width = size.width;
    c.height = size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child:Column(
        //  mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PositionedTapDetector(
            onTap: _onTap, //Pulsos en la pantalla
            onDoubleTap: _onDoubleTap,
            onLongPress: _onLongPress,
            child: CustomPaint(
              size: Size(size.width, size.height),
              painter: Dibujo(c.escenario, c.asignarPrimerPunto,c.marcado), //Dibujar el esenario
            ),
          ),
        ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: PopupMenuButton(itemBuilder: (context) => listOption(),color: Colors.yellowAccent,),
      ),
    );
  }

  Future _onTap(TapPosition position) async {
    if(this.select){
        c.insertarPunto(position.global.dx, position.global.dy);
    }else{//En modo seleccion
        if(this.selectPunto){
          c.selectPoligono(position.global.dx, position.global.dy);
        }else{//Modo seleccion y activado eliminar punto
          setState(() {
            c.eliminarPuntoSelect(position.global.dx, position.global.dy);
          });
        }
    }
    _updateState('gesture', position);
  }
  // void _onTap(TapPosition position) => _updateState('single tap', position);

  void _onDoubleTap(TapPosition position) {
    c.insertarPunto(position.global.dx, position.global.dy);
    c.cerrarPoligono();
    c.nuevoPoligono();
    _updateState('gesture', position);
  }

  void _onLongPress(TapPosition position) {
    c.nuevoPoligono();
    _updateState('long press', position);
  }

  void _updateState(String gesture, TapPosition position) {
    setState(() {
      _position = position;
    });
  }

  void guardarArchivo(String nombre) async {
    final Map map = clse.toMap(c);
    final file = File('/storage/emulated/0/Download/$nombre.odt');
    await file.writeAsString(json.encode(map));
    print(json.encode(map));
  }

  void abrirArchivo() async {
    _path = await FilePicker.getFilePath(
        type: _pickingType, fileExtension: _extension);
    final file = File(_path);
    String text = await file.readAsString();
    Map<String, dynamic> map = json.decode(text);
    Controlador decoded = clse.fromMap(map);
    setState(() {
      c = decoded;
      c.restablecerArea();
    });

    if (!mounted) return;
    setState(() {
      _fileName = _path != null ? _path.split('/').last : '...';
    });
  }

  void _modalGuardar() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Colors.green,
            height: 400,
            child: Container(
              child: _cuerpoModal(),
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(30),
                    topRight: const Radius.circular(30),
                  )),
            ),
          );
        }
    );
  }
  Column _cuerpoModal() {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.save),
          title: Text('Guardar Como'),
          onTap: () {
          },
        ),
        TextField( controller: nombreControler,),
        RaisedButton(
          child: Text('Guardar Archivo'),
          onPressed: (){
            guardarArchivo(nombreControler.text);
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  //Para poner nombre al nuevo registro del expediente
  void _mostrarAlerta(BuildContext context){
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context){//Contruyendo la alerta
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text("Nuevo Objeto"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: TextField(
                  controller: nombreObjeto,
                  decoration:InputDecoration(
                            labelText: 'Nombre del Objeto',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
                      ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                this.nombreObjeto.text="";//Lo vaciamos cuadno vuelve hacia atras porque sin esto se mantiene
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            FlatButton(
              onPressed: (){
                c.crearObjeto(nombreObjeto.text);
                Navigator.pop(context);//Para volver atras
              },//Aqui registramos el expediente
              child: Text('Guardar'),
            ),
          ],
        );
      }
    );
  }

  List<PopupMenuEntry<dynamic>> listOption() {
    return <PopupMenuEntry>[
      PopupMenuItem(
        child: ListTile(
          title: (this.select)?Text("Activar Seleccion",style: TextStyle(fontSize: 15))
                              :Text("Desactivar Seleccion",style: TextStyle(fontSize: 15)),
          leading: Icon(Icons.select_all,color:Colors.blue,),
          onTap: (){
            setState(() {
              this.select=!this.select;
              this.selectPunto=true;//Desactivo el eliminarPunto porque depende del select
              Navigator.pop(context);
            });
          },
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          title: Text("Limpiar Area",style: TextStyle(fontSize: 15),),
          leading: Icon(Icons.delete_forever,color: Colors.blue,),
          onTap: (){
              setState(() {
              c.limpiarArea();
              Navigator.pop(context);
            });
          },
        ),
      ),
      (c.marcado.length==1 && !c.objeto.getTipo)?//EDICION PARA UN SOLO POLIGONO
      PopupMenuItem(
        //eliminar ultimo punto
        child: ListTile(
          title: Text("Eliminar ultimo punto",style: TextStyle(fontSize: 15),),
          leading: Icon(Icons.delete_outline,color: Colors.blue,),
          onTap: (){
              setState(() {
              c.eliminarLastPunto();
              Navigator.pop(context);
            });
          },
        ),
      ):null,
      (c.marcado.length==1 && !c.objeto.getTipo)?//EDICION PARA UN SOLO POLIGONO
      PopupMenuItem(
        //eliminar ultimo punto
        child: ListTile(
          title: (this.selectPunto)?Text("Activar eliminacion de punto",style: TextStyle(fontSize: 15))
                              :Text("Desactivar eliminacion de punto",style: TextStyle(fontSize: 15)),
          leading: Icon(Icons.delete_outline,color: Colors.blue,),
          onTap: (){
            setState(() {
              this.selectPunto=!this.selectPunto;
              Navigator.pop(context);
            });
          },
        ),
      ):null,
      (c.marcado.length>=1)?//ELIMINACION
      PopupMenuItem(
        //eliminar seleccionas
        child: ListTile(
          title: Text("Eliminar seleccionados",style: TextStyle(fontSize: 15),),
          leading: Icon(Icons.delete_sweep,color: Colors.blue,),
          onTap: (){
            setState(() {
              c.eliminarSeleccionados();
              Navigator.pop(context);
            });
          },
        ),
      ):null,
      (c.marcado.length>=1 && !c.objeto.getTipo)?//CREAR OBJETO
      PopupMenuItem(
        //crear nuevo objeto
        child: ListTile(
          title: Text("Crear objeto",style: TextStyle(fontSize: 15),),
          leading: Icon(Icons.add_circle,color: Colors.blue,),
          onTap: (){
            _mostrarAlerta(context);
          },
        ),
      ):null,
      (c.objeto.getTipo)?//solo me muestra cuando un objeto esta seleccionado(!=0)
      PopupMenuItem(
        //Disolver Objeto cuando este esta seleccionado(!=0)
        child: ListTile(
          title: Text("Disolver objeto",style: TextStyle(fontSize: 15),),
          leading: Icon(Icons.add_circle,color: Colors.blue,),
          onTap: (){
            c.disolverObjeto();
            Navigator.pop(context);
          },
        ),
      ):null,
      (c.objeto.getTipo)?//solo me muestra cuando un objeto esta seleccionado(!=0)
      PopupMenuItem(
        //Une un nuevo poligono al objeto solucionado
        child: ListTile(
          title: Text("Fusionar objeto",style: TextStyle(fontSize: 15),),
          leading: Icon(Icons.add_box,color: Colors.blue,),
          onTap: (){
            c.fusionarObjeto();
            Navigator.pop(context);
          },
        ),
      ):null,
      PopupMenuItem(
        //ABRIR
        child: ListTile(
          title: Text("Abrir",style: TextStyle(fontSize: 15),),
          leading: Icon(Icons.open_in_browser,color: Colors.blue,),
          onTap: (){
              setState(() {
              abrirArchivo();
              Navigator.pop(context);
            });
          },
        ),
      ),
      PopupMenuItem(
        //GUARDAR
        child: ListTile(
          title: Text("Guardar",style: TextStyle(fontSize: 15),),
          leading: Icon(Icons.save,color: Colors.blue,),
          onTap: (){
              setState(() {
              Navigator.pop(context);
              _modalGuardar();
            });
          },
        ),
      ),
      (c.marcado.length>0)?//solo muestro cuando seleccionan
      PopupMenuItem(
        //Color
        child: ListTile(
          title: Text("Color",style: TextStyle(fontSize: 15),),
          leading: Icon(Icons.color_lens,color: Colors.blue,),
          onTap: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        titlePadding: const EdgeInsets.all(0.0),
                        contentPadding: const EdgeInsets.all(0.0),
                        content: SingleChildScrollView(
                          child: MaterialPicker(
                            pickerColor: currentColor,
                            onColorChanged: changeColor,
                            enableLabel: true,
                          ),
                        ),
                      );
                    },
                  );
          },
        ),
      ):null,
      /*PopupMenuItem(
        //crear nuevo objeto
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                    MaterialPageRoute(builder: (context)=>prefix0.MainPage(controlador:c))
                  );
          },
          child: Icon(Icons.bluetooth),
        ),
      ),
       PopupMenuItem(
        //crear nuevo objeto
        child: FloatingActionButton(
          onPressed: (){
               c.dataBluetooth();
          },
          child: Icon(Icons.send),
        ),
      ),*/
    ];
  }
  
  void changeColor(Color color){
    setState(() => currentColor = color);
    c.cambiarColor(this.currentColor.value);
    Navigator.pop(context);
  }
}
