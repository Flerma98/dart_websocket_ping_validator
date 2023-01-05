import 'dart:io';

class WebSocketPingValidatorProperties {
  final Function(dynamic) onMessage;
  final Function(DateTime)? onConnected;
  final Function(Object)? onError;
  final Function(int)? onConnectionClosed;
  final Function? onConnectionLost;
  final Function(Duration)? onReconnectStarted;
  final Function(WebSocket) onNewInstanceCreated;
  final bool reconnectOnError;
  final bool reconnectOnConnectionLost;
  final Duration periodicDurationToMakePing;
  final Duration reconnectIn;
  final bool validateIfCanMakeConnection;

  WebSocketPingValidatorProperties(
      {required this.onMessage,
      this.onConnected,
      this.onError,
      this.onConnectionClosed,
      this.onConnectionLost,
      this.onReconnectStarted,
      required this.onNewInstanceCreated,
      required this.reconnectOnError,
      this.reconnectOnConnectionLost = true,
      this.periodicDurationToMakePing = const Duration(seconds: 5),
      this.reconnectIn = const Duration(seconds: 3),
      this.validateIfCanMakeConnection = true});
}
