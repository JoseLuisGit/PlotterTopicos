import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:plottertopicos/negocio/controlador.dart';
import 'package:scoped_model/scoped_model.dart';

import 'dart:convert';
import 'Dispositivo.dart';

//import './LineChart.dart';

class MainPage extends StatefulWidget {
  final Controlador controlador;
  const MainPage({Key key, @required this.controlador}) : super(key: key);
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _direccion = "...";
  String _nombre = "...";

  Timer _tiempoListar;
  int _discoverableTimeoutSecondsLeft = 0;
  BluetoothDevice selectedDevice;
  BluetoothConnection connection;
  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _direccion = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _nombre = name;
      });
    });

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        _tiempoListar = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _tiempoListar?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            SwitchListTile(
              title: const Text('Activar Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                future() async {
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }

                future().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title: const Text('Nombre Adaptador'),
              subtitle: Text(_nombre),
              onLongPress: null,
            ),
            Divider(),
            ListTile(
              title: RaisedButton(
                  child: const Text('Enviar'),
                  onPressed: () async {
                    //  print(selectedDevice.address);

                    connection.output.add(
                        utf8.encode(this.widget.controlador.dataBluetooth()));
                    await connection.output.allSent;
                    // print(this
                    //     .separarCadena(this.widget.controlador.dataBluetooth())
                    //     .toString());
                    // List<String> env = this
                    //     .separarCadena(this.widget.controlador.dataBluetooth());
                    // int i = 0;
                    // while (i < env.length) {
                   
                    //   print(env[i]);
                     
                    //      i++;
                    //  await justWait(numberOfSeconds: 5);
                    // }

                    // connection.input.listen((onData) {
                    //   print(onData);
                    // });
                    //connection.output.add(utf8.encode(this.widget.controlador.dataBluetooth()));
                    //await connection.output.allSent;
                  }),
            ),
            ListTile(
              title: RaisedButton(
                  child: const Text('Explorar dispositivos'),
                  onPressed: () async {
                    final BluetoothDevice selectedDevice =
                        await Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                      return DiscoveryPage();
                    }));

                    if (selectedDevice != null) {
                      print('Discovery -> selected ' + selectedDevice.address);
                    } else {
                      print('Discovery -> no device selected');
                    }
                  }),
            ),
            ListTile(
              title: RaisedButton(
                child: ((selectedDevice != null)
                    ? const Text('Desconectar')
                    : const Text('Conectar')),
                onPressed: () async {
                  if (selectedDevice != null) {
                    connection.cancel();
                    setState(() {
                      /* Update for `_collectingTask.inProgress` */
                    });
                  } else {
                    BluetoothDevice _selectedDevice =
                        await Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                      return SelectBondedDevicePage(checkAvailability: false);
                    }));
                    setState(() {
                      selectedDevice = _selectedDevice;
                    });

                    BluetoothConnection.toAddress(selectedDevice.address)
                        .then((_connection) {
                      setState(() {
                        connection = _connection;
                      });
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

 
void justWait({@required int numberOfSeconds}) async {
    await Future.delayed(Duration(seconds: numberOfSeconds));
  }

  List<String> separarCadena(String data) {
    List<String> listaCadena = data.split(',');
    List<String> enviarLista = new List<String>();
    int i = 0;
    String cadenita = "";

    for (int j = 0; j < listaCadena.length; j++) {
      i += listaCadena[j].length + 1;

      if (i <= 128) {
        cadenita = cadenita + listaCadena[j] + ",";
      } else {
        i = 0;
        enviarLista.add(cadenita);
        cadenita = "";
      }
    }

    enviarLista.add(cadenita);

    return enviarLista;
  }
}

class SelectBondedDevicePage extends StatefulWidget {
  final bool checkAvailability;

  const SelectBondedDevicePage({this.checkAvailability = true});

  @override
  _SelectBondedDevicePage createState() => new _SelectBondedDevicePage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>();

  // Availability
  StreamSubscription<BluetoothDiscoveryResult> _discoveryStreamSubscription;
  bool _isDiscovering;

  _SelectBondedDevicePage();

  @override
  void initState() {
    super.initState();

    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering) {
      _startDiscovery();
    }

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map((device) => _DeviceWithAvailability(
                device,
                widget.checkAvailability
                    ? _DeviceAvailability.maybe
                    : _DeviceAvailability.yes))
            .toList();
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var _device = i.current;
          if (_device.device == r.device) {
            _device.availability = _DeviceAvailability.yes;
            _device.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
        .map((_device) => BluetoothDeviceListEntry(
              device: _device.device,
              rssi: _device.rssi,
              enabled: _device.availability == _DeviceAvailability.yes,
              onTap: () {
                Navigator.of(context).pop(_device.device);
              },
            ))
        .toList();
    return Scaffold(
        appBar: AppBar(
          title: Text('Seleccionar dispositivo'),
          actions: <Widget>[
            (_isDiscovering
                ? FittedBox(
                    child: Container(
                        margin: new EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white))))
                : IconButton(
                    icon: Icon(Icons.replay), onPressed: _restartDiscovery))
          ],
        ),
        body: ListView(children: list));
  }
}
