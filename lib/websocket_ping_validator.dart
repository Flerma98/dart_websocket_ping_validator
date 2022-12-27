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
      int attempt = 1;
      final webSocketConnection = await WebSocket.connect(url);

      if (properties.onConnected != null) {
        await properties.onConnected!(DateTime.now());
      }
      webSocketConnection.listen((message) async {
        attempt = 1;
        await properties.onMessage(message);
      }, onError: (error) async {
        if (properties.onError != null) {
          await properties.onError!(error);
        }
        if (properties.reconnectOnError) {
          await _reconnect(url, properties: properties);
        }
      }, onDone: () async {
        if (properties.onConnectionClosed != null) {
          await properties.onConnectionClosed!(
              webSocketConnection.closeCode ?? WebSocketStatus.normalClosure);
        }
      }, cancelOnError: true);

      if (properties.dataToSendAsPing != null) {
        Timer.periodic(properties.periodicDurationToPing, (timer) async {
          try {
            if (webSocketConnection.closeCode != null) {
              timer.cancel();
              return;
            }

            if (properties.onAttemptChanged != null) {
              await properties.onAttemptChanged!(attempt);
            }

            webSocketConnection.add(properties.dataToSendAsPing);

            if (attempt >= properties.maxAttempts) {
              timer.cancel();
              if (properties.onConnectionLost != null) {
                await properties.onConnectionLost!();
              }

              await webSocketConnection.close();

              await properties.onNewInstanceCreated(
                  await _reconnect(url, properties: properties));
              return;
            }
          } catch (error) {
            timer.cancel();

            if (properties.onError != null) {
              await properties.onError!(error);
            }

            if (properties.onConnectionLost != null) {
              await properties.onConnectionLost!();
            }

            if (webSocketConnection.closeCode == null) {
              await webSocketConnection.close();
            }

            if (properties.reconnectOnError) {
              await properties.onNewInstanceCreated(
                  await _reconnect(url, properties: properties));
            }
            return;
          }
          attempt = attempt += 1;
        });
      }
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
