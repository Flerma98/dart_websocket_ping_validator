library websocket_ping_validator;

import 'dart:async';
import 'dart:io';

import 'package:websocket_ping_validator/utilities/error_status_code.dart';

abstract class WebsocketPingValidator {
  static Future<WebSocket> connectWebSocket(final String url,
      {required final Function(dynamic) onMessage,
      final Function(DateTime)? onConnected,
      final Function(Object)? onError,
      final Function(int)? onConnectionClosed,
      final Function(int)? onAttemptChanged,
      final Function? onConnectionLost,
      final Function(Duration)? onReconnectStarted,
      required final bool reconnectOnError,
      required final dynamic dataToSendAsPing,
      final int maxAttempts = 5,
      final Duration periodicDurationToPing = const Duration(seconds: 3),
      final Duration reconnectIn = const Duration(seconds: 3),
      final bool validateIfCanMakeConnection = true}) async {
    if (!validateIfCanMakeConnection) {
      throw ErrorStatusCode.validateIfCanMakeConnectionUnfulfilled;
    }

    try {
      int attempt = 1;
      WebSocket webSocketConnection = await WebSocket.connect(url);

      if (onConnected != null) await onConnected(DateTime.now());
      webSocketConnection.listen((message) async {
        attempt = 1;
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
            if (onAttemptChanged != null) {
              await onAttemptChanged(attempt);
            }

            webSocketConnection.add(dataToSendAsPing);

            if (attempt >= maxAttempts) {
              timer.cancel();
              if (onConnectionLost != null) {
                await onConnectionLost();
              }
              await webSocketConnection.close();
              webSocketConnection = await _reconnect(url,
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
          } catch (error) {
            if (onError != null) {
              await onError(error);
            }
          }
          attempt = attempt += 1;
        });
      }
      return webSocketConnection;
    } catch (error) {
      if (onError != null) {
        await onError(error);
      }
      if (reconnectOnError) {
        return await _reconnect(url,
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
      rethrow;
    }
  }

  static Future<WebSocket> _reconnect(final String url,
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
    return await connectWebSocket(url,
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
