import 'dart:io';

class WebSocketPingValidatorProperties {
  final void Function(dynamic) onMessage;
  final void Function(DateTime, WebSocket)? onConnected;
  final void Function(Object)? onError;
  final void Function(int, String?)? onConnectionClosed;
  final void Function()? onConnectionLost;
  final void Function(Duration)? onReconnectStarted;
  final void Function(WebSocket) onNewInstanceCreated;
  final Future<bool> Function() reconnectOnError;
  final Future<bool> Function() reconnectOnConnectionLost;
  final Duration periodicDurationToMakePing;
  final Duration reconnectIn;
  final Future<bool> Function() validateIfCanMakeConnection;

  WebSocketPingValidatorProperties({
    required this.onMessage,
    this.onConnected,
    this.onError,
    this.onConnectionClosed,
    this.onConnectionLost,
    this.onReconnectStarted,
    required this.onNewInstanceCreated,
    required this.reconnectOnError,
    final Future<bool> Function()? reconnectOnConnectionLost,
    this.periodicDurationToMakePing = const Duration(seconds: 5),
    this.reconnectIn = const Duration(seconds: 3),
    final Future<bool> Function()? validateIfCanMakeConnection,
  })  : reconnectOnConnectionLost =
            reconnectOnConnectionLost ?? (() async => true),
        validateIfCanMakeConnection =
            validateIfCanMakeConnection ?? (() async => true);
}
