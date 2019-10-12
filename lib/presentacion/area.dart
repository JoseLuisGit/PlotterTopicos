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

class areaPage extends StatefulWidget {
  areaPage({Key key}) : super(key: key);

  _areaPageState createState() => _areaPageState();
}

class _areaPageState extends State<areaPage> {
  Controlador c = new Controlador();
  ControladorJsonSerializer clse = new ControladorJsonSerializer();
  TapPosition _position = TapPosition(Offset.zero, Offset.zero);
  TextEditingController nombreControler = new TextEditingController();
  ///variables de filepicker
  String _fileName;
  String _path;

  String _extension = 'odt';

  FileType _pickingType = FileType.CUSTOM;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(size.width);
    print(size.height);
    c.width = size.width;
    c.height = size.height;
    return Scaffold(
      body: Column(
        //  mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PositionedTapDetector(
            onTap: _onTap, //Pulsos en la pantalla
            onDoubleTap: _onDoubleTap,
            onLongPress: _onLongPress,
            child: CustomPaint(
              size: Size(size.width, size.height),
              painter: Dibujo(
                  c.escenario, c.asignarPrimerPunto), //Dibujar el esenario
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: PopupMenuButton(itemBuilder: (context) => listOption()),
      ),
    );
  }

  Future _onTap(TapPosition position) async {

    c.insertarPunto(position.global.dx, position.global.dy);
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
    });

    if (!mounted) return;
    setState(() {
      _fileName = _path != null ? _path.split('/').last : '...';
    });
  }


  void _onButtonPressed() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Colors.green,
            height: 400,
            child: Container(
              child: _column(),
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(30),
                    topRight: const Radius.circular(30),
                  )),
            ),
          );
        });
  }


    Column _column() {
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

  List<PopupMenuEntry<dynamic>> listOption() {
    return <PopupMenuEntry>[
      PopupMenuItem(
        //limpiar area
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              c.limpiarArea();
            });
          },
          child: Icon(Icons.delete_forever),
        ),
      ),
      PopupMenuItem(
        //eliminar ultimo trazo
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              c.eliminarLastPunto();
            });
          },
          child: Icon(Icons.delete_outline),
        ),
      ),
      PopupMenuItem(
        //crear nuevo objeto
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              c.nuevoObjeto();
            });
          },
          child: Icon(Icons.add_circle),
        ),
      ),
      PopupMenuItem(
        //abrirArchivo
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              abrirArchivo();
            });
          },
          child: Icon(Icons.open_in_browser),
        ),
      ),
      PopupMenuItem(
        //crear nuevo objeto
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _onButtonPressed();
            });
          },
          child: Icon(Icons.save),
        ),
      ),
      PopupMenuItem(
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
      ),
    ];
  }
}
