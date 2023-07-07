library websocket_ping_validator;

import 'dart:async';
import 'dart:io';

import 'package:websocket_ping_validator/utilities/error_status_code.dart';
import 'package:websocket_ping_validator/utilities/properties.dart';

abstract class WebsocketPingValidator {
  static Future<WebSocket> connectWebSocket(final String url,
      {required final WebSocketPingValidatorProperties properties,
      final Iterable<String>? protocols,
      final Map<String, dynamic>? headers,
      final CompressionOptions compression =
          CompressionOptions.compressionDefault,
      final HttpClient? customClient}) async {
    if (!properties.validateIfCanMakeConnection) {
      throw ErrorStatusCode.validateIfCanMakeConnectionUnfulfilled;
    }

    late WebSocket webSocketConnection;

    try {
      webSocketConnection = await WebSocket.connect(url,
          protocols: protocols,
          headers: headers,
          compression: compression,
          customClient: customClient);

      webSocketConnection.pingInterval = properties.periodicDurationToMakePing;

      if (properties.onConnected != null) {
        await properties.onConnected!(DateTime.now());
      }
      webSocketConnection.listen(properties.onMessage, onError: (error) async {
        if (properties.onError != null) {
          await properties.onError!(error);
        }
        if (properties.reconnectOnError) {
          try {
            await webSocketConnection.close(
                WebSocketStatus.abnormalClosure, error.toString());
          } catch (error) {
            ///ignore
          }
          await _reconnect(url, properties: properties);
        }
      }, onDone: () async {
        final closeCode =
            webSocketConnection.closeCode ?? WebSocketStatus.normalClosure;

        try {
          await webSocketConnection.close(
              closeCode, webSocketConnection.closeReason);
        } catch (error) {
          ///ignore
        }

        if (properties.reconnectOnConnectionLost &&
            closeCode == WebSocketStatus.goingAway) {
          if (properties.onConnectionLost != null) {
            await properties.onConnectionLost!();
          }

          await properties.onNewInstanceCreated(
              await _reconnect(url, properties: properties));
          return;
        }
        if (properties.onConnectionClosed != null) {
          await properties.onConnectionClosed!(
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
