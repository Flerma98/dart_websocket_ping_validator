import 'dart:io';

class WebSocketPingValidatorProperties {
  final void Function(dynamic) onMessage;
  final void Function(DateTime)? onConnected;
  final void Function(Object)? onError;
  final void Function(int, String?)? onConnectionClosed;
  final void Function()? onConnectionLost;
  final void Function(Duration)? onReconnectStarted;
  final void Function(WebSocket) onNewInstanceCreated;
  final bool Function() reconnectOnError;
  final bool Function() reconnectOnConnectionLost;
  final Duration periodicDurationToMakePing;
  final Duration reconnectIn;
  final bool Function() validateIfCanMakeConnection;

  WebSocketPingValidatorProperties({
    required this.onMessage,
    this.onConnected,
    this.onError,
    this.onConnectionClosed,
    this.onConnectionLost,
    this.onReconnectStarted,
    required this.onNewInstanceCreated,
    required this.reconnectOnError,
    final bool Function()? reconnectOnConnectionLost,
    this.periodicDurationToMakePing = const Duration(seconds: 5),
    this.reconnectIn = const Duration(seconds: 3),
    final bool Function()? validateIfCanMakeConnection,
  })  : reconnectOnConnectionLost = reconnectOnConnectionLost ?? (() => true),
        validateIfCanMakeConnection =
            validateIfCanMakeConnection ?? (() => true);
}
