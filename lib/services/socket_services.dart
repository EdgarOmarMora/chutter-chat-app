import 'package:chat/global/environment.dart';
import 'package:chat/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket? _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket? get socket => _socket;
  Function get emit => _socket!.emit;

  void connect() async {
    final token = await AuthService.getToken();

    // Dart Client
    _socket = IO.io(Environment.socketUrl, {
      //_socket = IO.io('https://flutter-socket-server-edgar.herokuapp.com/', {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
      'extraHeaders': {'x-token': token},
    });

    _socket?.on('connect', (_) {
      //print('connect');
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket?.on('disconnect', (_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    /* socket.on('nuevo-mensaje', (payload) {
      print('nuevo-mensaje:');
      print('nombre: ' + payload['nombre']);
      print('mensaje: ' + payload['mensaje']);
      print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'no hay');
    }); */
  }

  void disconnect() {
    _socket?.disconnect();
  }
}
