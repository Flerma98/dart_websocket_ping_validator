library websocket_ping_validator;

import 'dart:async';
import 'dart:io';

import 'package:websocket_ping_validator/utilities/error_status_code.dart';
import 'package:websocket_ping_validator/utilities/properties.dart';

abstract class WebsocketPingValidator {
  static Future<WebSocket> connectWebSocket(
      final Future<WebSocket> Function() webSocket,
      {required final WebSocketPingValidatorProperties properties}) async {
    if (!(await properties.validateIfCanMakeConnection())) {
      throw ErrorStatusCode.validateIfCanMakeConnectionUnfulfilled;
    }

    late final WebSocket webSocketConnection;
    late final StreamSubscription subscription;

    try {
      webSocketConnection = await webSocket();

      webSocketConnection.pingInterval = properties.periodicDurationToMakePing;

      if (properties.onConnected != null) {
        properties.onConnected!(DateTime.now());
      }

      subscription = webSocketConnection.listen(properties.onMessage,
          onError: (error) async {
        if (properties.onError != null) {
          properties.onError!(error);
        }
        if (await properties.reconnectOnError()) {
          try {
            await webSocketConnection.close(
                WebSocketStatus.abnormalClosure, error.toString());
          } catch (error) {
            ///ignore
          }
          await _reconnect(webSocket, properties: properties);
        }
      }, onDone: () async {
        await subscription.cancel();

        final closeCode =
            webSocketConnection.closeCode ?? WebSocketStatus.normalClosure;

        try {
          await webSocketConnection.close(
              closeCode, webSocketConnection.closeReason);
        } catch (error) {
          ///ignore
        }

        if (await properties.reconnectOnConnectionLost() &&
            closeCode == WebSocketStatus.goingAway) {
          if (properties.onConnectionLost != null) {
            properties.onConnectionLost!();
          }

          properties.onNewInstanceCreated(
              await _reconnect(webSocket, properties: properties));
          return;
        }
        if (properties.onConnectionClosed != null) {
          properties.onConnectionClosed!(
              closeCode, webSocketConnection.closeReason);
        }
      }, cancelOnError: true);
      return webSocketConnection;
    } catch (error) {
      try {
        await webSocketConnection.close(
            WebSocketStatus.abnormalClosure, error.toString());
      } catch (error) {
        ///ignore
      }
      if (properties.onError != null) {
        properties.onError!(error);
      }
      if (await properties.reconnectOnError()) {
        return await _reconnect(webSocket, properties: properties);
      }
      rethrow;
    }
  }

  static Future<WebSocket> _reconnect(
      final Future<WebSocket> Function() webSocket,
      {required final WebSocketPingValidatorProperties properties}) async {
    if (properties.onReconnectStarted != null) {
      properties.onReconnectStarted!(properties.reconnectIn);
    }
    await Future.delayed(properties.reconnectIn);
    return await connectWebSocket(webSocket, properties: properties);
  }
}
