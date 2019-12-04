// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$PuntoJsonSerializer implements Serializer<Punto> {
  @override
  Map<String, dynamic> toMap(Punto model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'getX', model.getX);
    setMapValue(ret, 'getY', model.getY);
    setMapValue(ret, 'x', model.x);
    setMapValue(ret, 'y', model.y);
    return ret;
  }

  @override
  Punto fromMap(Map map) {
    if (map == null) return null;
    final obj = Punto(getJserDefault('x'), getJserDefault('y'));
    obj.x = map['x'] as double;
    obj.y = map['y'] as double;
    return obj;
  }
}

abstract class _$PoligonoJsonSerializer implements Serializer<Poligono> {
  Serializer<Punto> __puntoJsonSerializer;
  Serializer<Punto> get _puntoJsonSerializer =>
      __puntoJsonSerializer ??= PuntoJsonSerializer();
  @override
  Map<String, dynamic> toMap(Poligono model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'getColor', model.getColor);
    setMapValue(ret, 'getTipo', model.getTipo);
    setMapValue(
        ret,
        'puntos',
        codeIterable(
            model.puntos, (val) => _puntoJsonSerializer.toMap(val as Punto)));
    setMapValue(ret, 'tipo', model.tipo);
    setMapValue(ret, 'color', model.color);
    return ret;
  }

  @override
  Poligono fromMap(Map map) {
    if (map == null) return null;
    final obj = Poligono();
    obj.puntos = codeIterable<Punto>(map['puntos'] as Iterable,
        (val) => _puntoJsonSerializer.fromMap(val as Map));
    obj.tipo = map['tipo'] as bool;
    obj.color = map['color'] as int;
    return obj;
  }
}

abstract class _$ObjetoJsonSerializer implements Serializer<Objeto> {
  Serializer<Poligono> __poligonoJsonSerializer;
  Serializer<Poligono> get _poligonoJsonSerializer =>
      __poligonoJsonSerializer ??= PoligonoJsonSerializer();
  @override
  Map<String, dynamic> toMap(Objeto model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'getNombre', model.getNombre);
    setMapValue(ret, 'getTipo', model.getTipo);
    setMapValue(
        ret,
        'poligonos',
        codeIterable(model.poligonos,
            (val) => _poligonoJsonSerializer.toMap(val as Poligono)));
    setMapValue(ret, 'nombre', model.nombre);
    setMapValue(ret, 'tipo', model.tipo);
    return ret;
  }

  @override
  Objeto fromMap(Map map) {
    if (map == null) return null;
    final obj = Objeto();
    obj.poligonos = codeIterable<Poligono>(map['poligonos'] as Iterable,
        (val) => _poligonoJsonSerializer.fromMap(val as Map));
    obj.nombre = map['nombre'] as String;
    obj.tipo = map['tipo'] as bool;
    return obj;
  }
}

abstract class _$EscenarioJsonSerializer implements Serializer<Escenario> {
  Serializer<Objeto> __objetoJsonSerializer;
  Serializer<Objeto> get _objetoJsonSerializer =>
      __objetoJsonSerializer ??= ObjetoJsonSerializer();
  @override
  Map<String, dynamic> toMap(Escenario model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(
        ret,
        'objetos',
        codeIterable(model.objetos,
            (val) => _objetoJsonSerializer.toMap(val as Objeto)));
    return ret;
  }

  @override
  Escenario fromMap(Map map) {
    if (map == null) return null;
    final obj = Escenario();
    obj.objetos = codeIterable<Objeto>(map['objetos'] as Iterable,
        (val) => _objetoJsonSerializer.fromMap(val as Map));
    return obj;
  }
}

abstract class _$ControladorJsonSerializer implements Serializer<Controlador> {
  Serializer<Escenario> __escenarioJsonSerializer;
  Serializer<Escenario> get _escenarioJsonSerializer =>
      __escenarioJsonSerializer ??= EscenarioJsonSerializer();
  Serializer<Objeto> __objetoJsonSerializer;
  Serializer<Objeto> get _objetoJsonSerializer =>
      __objetoJsonSerializer ??= ObjetoJsonSerializer();
  Serializer<Poligono> __poligonoJsonSerializer;
  Serializer<Poligono> get _poligonoJsonSerializer =>
      __poligonoJsonSerializer ??= PoligonoJsonSerializer();
  @override
  Map<String, dynamic> toMap(Controlador model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(
        ret, 'escenario', _escenarioJsonSerializer.toMap(model.escenario));
    setMapValue(ret, 'objeto', _objetoJsonSerializer.toMap(model.objeto));
    setMapValue(ret, 'poligono', _poligonoJsonSerializer.toMap(model.poligono));
    setMapValue(ret, 'asignarPrimerPunto', model.asignarPrimerPunto);
    setMapValue(ret, 'width', model.width);
    setMapValue(ret, 'height', model.height);
    setMapValue(
        ret,
        'marcado',
        codeIterable(model.marcado,
            (val) => _poligonoJsonSerializer.toMap(val as Poligono)));
    return ret;
  }

  @override
  Controlador fromMap(Map map) {
    if (map == null) return null;
    final obj = Controlador();
    obj.escenario = _escenarioJsonSerializer.fromMap(map['escenario'] as Map);
    obj.objeto = _objetoJsonSerializer.fromMap(map['objeto'] as Map);
    obj.poligono = _poligonoJsonSerializer.fromMap(map['poligono'] as Map);
    obj.asignarPrimerPunto = map['asignarPrimerPunto'] as bool;
    obj.width = map['width'] as double;
    obj.height = map['height'] as double;
    obj.marcado = codeIterable<Poligono>(map['marcado'] as Iterable,
        (val) => _poligonoJsonSerializer.fromMap(val as Map));
    return obj;
  }
}
