import 'dart:io';

class WebSocketPingValidatorProperties {
  final Function(dynamic) onMessage;
  final Function(DateTime)? onConnected;
  final Function(Object)? onError;
  final Function(int)? onConnectionClosed;
  final Function(int)? onAttemptChanged;
  final Function? onConnectionLost;
  final Function(Duration)? onReconnectStarted;
  final Function(WebSocket) onNewInstanceCreated;
  final bool reconnectOnError;
  final dynamic dataToSendAsPing;
  final int maxAttempts;
  final Duration periodicDurationToPing;
  final Duration reconnectIn;
  final bool validateIfCanMakeConnection;

  WebSocketPingValidatorProperties(
      {required this.onMessage,
      this.onConnected,
      this.onError,
      this.onConnectionClosed,
      this.onAttemptChanged,
      this.onConnectionLost,
      this.onReconnectStarted,
      required this.onNewInstanceCreated,
      required this.reconnectOnError,
      required this.dataToSendAsPing,
      this.maxAttempts = 5,
      this.periodicDurationToPing = const Duration(seconds: 3),
      this.reconnectIn = const Duration(seconds: 3),
      this.validateIfCanMakeConnection = true});
}
