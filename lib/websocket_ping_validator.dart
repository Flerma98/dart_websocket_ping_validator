library websocket_ping_validator;

import 'dart:async';
import 'dart:io';

abstract class WebsocketPingValidator {
  static Future<void> connectWebSocket(final String url,
      {required final Function(dynamic) onMessage,
      final Function(DateTime)? onConnected,
      final Function(Object)? onError,
      final Function(int)? onConnectionClosed,
      final Function? onConnectionLost,
      final Function(Duration)? onReconnectStarted,
      required final bool reconnectOnError,
      required final dynamic dataToSendAsPing,
      final int maxAttempts = 5,
      final Duration periodicDurationToPing = const Duration(seconds: 3),
      final Duration reconnectIn = const Duration(seconds: 3),
      final bool validateIfCanMakeConnection = true}) async {
    try {
      if (!validateIfCanMakeConnection) return;

      int retry = 1;
      final webSocketConnection = await WebSocket.connect(url);
      if (onConnected != null) await onConnected(DateTime.now());
      webSocketConnection.listen((message) async {
        retry = 1;
        await onMessage(message);
      }, onError: (error) async {
        if (onError != null) {
          await onError(error);
        }
        if (reconnectOnError) {
          await _reconnect(url,
              onMessage: onMessage,
              onConnected: onConnected,
              onError: onError,
              onConnectionClosed: onConnectionClosed,
              onConnectionLost: onConnectionLost,
              onReconnectStarted: onReconnectStarted,
              reconnectOnError: reconnectOnError,
              dataToSendAsPing: dataToSendAsPing,
              maxAttempts: maxAttempts,
              periodicDurationToPing: periodicDurationToPing,
              reconnectIn: reconnectIn);
        }
      }, onDone: () async {
        if (onConnectionClosed != null) {
          await onConnectionClosed(
              webSocketConnection.closeCode ?? WebSocketStatus.normalClosure);
        }
      }, cancelOnError: true);

      if (dataToSendAsPing != null) {
        Timer.periodic(periodicDurationToPing, (timer) async {
          try {
            webSocketConnection.add(dataToSendAsPing);
            if (retry >= maxAttempts) {
              timer.cancel();
              if (onConnectionLost != null) {
                await onConnectionLost();
              }
              await webSocketConnection.close();
              await _reconnect(url,
                  onMessage: onMessage,
                  onConnected: onConnected,
                  onError: onError,
                  onConnectionClosed: onConnectionClosed,
                  onConnectionLost: onConnectionLost,
                  onReconnectStarted: onReconnectStarted,
                  reconnectOnError: reconnectOnError,
                  dataToSendAsPing: dataToSendAsPing,
                  maxAttempts: maxAttempts,
                  periodicDurationToPing: periodicDurationToPing,
                  reconnectIn: reconnectIn);
              return;
            }
            retry += 1;
          } catch (error) {
            ///IGNORE
          }
        });
      }
    } catch (error) {
      if (onError != null) {
        await onError(error);
      }
      if (reconnectOnError) {
        await _reconnect(url,
            onMessage: onMessage,
            onConnected: onConnected,
            onError: onError,
            onConnectionClosed: onConnectionClosed,
            onConnectionLost: onConnectionLost,
            onReconnectStarted: onReconnectStarted,
            reconnectOnError: reconnectOnError,
            dataToSendAsPing: dataToSendAsPing,
            maxAttempts: maxAttempts,
            periodicDurationToPing: periodicDurationToPing,
            reconnectIn: reconnectIn);
      }
    }
  }

  static Future<void> _reconnect(final String url,
      {required final Function(dynamic) onMessage,
      final Function(DateTime)? onConnected,
      final Function(Object)? onError,
      final Function(int)? onConnectionClosed,
      final Function? onConnectionLost,
      final Function(Duration)? onReconnectStarted,
      required final bool reconnectOnError,
      required final dynamic dataToSendAsPing,
      final int maxAttempts = 5,
      final Duration periodicDurationToPing = const Duration(seconds: 3),
      final Duration reconnectIn = const Duration(seconds: 3)}) async {
    if (onReconnectStarted != null) {
      await onReconnectStarted(reconnectIn);
    }
    await Future.delayed(reconnectIn);
    await connectWebSocket(url,
        onMessage: onMessage,
        onConnected: onConnected,
        onError: onError,
        onConnectionClosed: onConnectionClosed,
        onConnectionLost: onConnectionLost,
        onReconnectStarted: onReconnectStarted,
        reconnectOnError: reconnectOnError,
        dataToSendAsPing: dataToSendAsPing,
        maxAttempts: maxAttempts,
        periodicDurationToPing: periodicDurationToPing,
        reconnectIn: reconnectIn);
  }
}
