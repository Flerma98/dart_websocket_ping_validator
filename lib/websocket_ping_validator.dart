library websocket_ping_validator;

import 'dart:async';
import 'dart:io';

import 'package:websocket_ping_validator/utilities/error_status_code.dart';
import 'package:websocket_ping_validator/utilities/properties.dart';

abstract class WebsocketPingValidator {
  static Future<WebSocket> connectWebSocket(final String url,
      {required final WebSocketPingValidatorProperties properties}) async {
    if (!properties.validateIfCanMakeConnection) {
      throw ErrorStatusCode.validateIfCanMakeConnectionUnfulfilled;
    }

    try {
      final webSocketConnection = await WebSocket.connect(url);

      webSocketConnection.pingInterval = properties.periodicDurationToMakePing;

      if (properties.onConnected != null) {
        await properties.onConnected!(DateTime.now());
      }
      webSocketConnection.listen(properties.onMessage, onError: (error) async {
        if (properties.onError != null) {
          await properties.onError!(error);
        }
        if (properties.reconnectOnError) {
          await _reconnect(url, properties: properties);
        }
      }, onDone: () async {
        final closeCode =
            webSocketConnection.closeCode ?? WebSocketStatus.normalClosure;
        if (properties.reconnectOnConnectionLost &&
            closeCode == WebSocketStatus.goingAway) {
          if (properties.onConnectionLost != null) {
            await properties.onConnectionLost!();
          }

          await webSocketConnection.close();

          await properties.onNewInstanceCreated(
              await _reconnect(url, properties: properties));
          return;
        }
        if (properties.onConnectionClosed != null) {
          await properties.onConnectionClosed!(closeCode);
        }
      }, cancelOnError: true);
      return webSocketConnection;
    } catch (error) {
      if (properties.onError != null) {
        await properties.onError!(error);
      }
      if (properties.reconnectOnError) {
        return await _reconnect(url, properties: properties);
      }
      rethrow;
    }
  }

  static Future<WebSocket> _reconnect(final String url,
      {required final WebSocketPingValidatorProperties properties}) async {
    if (properties.onReconnectStarted != null) {
      await properties.onReconnectStarted!(properties.reconnectIn);
    }
    await Future.delayed(properties.reconnectIn);
    return await connectWebSocket(url, properties: properties);
  }
}
