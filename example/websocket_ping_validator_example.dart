import 'dart:typed_data';

import 'package:websocket_ping_validator/websocket_ping_validator.dart';

void main() async {
  ///Type: String
  ///YOUR WEBSOCKET URL
  const url = "ws...";

  ///Type: bool
  ///VARIABLE SPECIFICITIES IF YOU WANT TO RECONNECT WHEN A ERROR HAVE OCCURRED
  const reconnectOnError = true;

  ///Type: dynamic (NOT NULL)
  ///IS THE DATA SENT TO SERVER TO MAKE A PING
  final dataToSendAsPing = Uint8List.fromList([0]);

  ///Type: int
  ///IS THE MAX COUNT OF ATTEMPTS TO MAKE A PING
  const maxAttempts = 5;

  ///Type: Duration
  ///IS DURATION OF TIME TO MAKE A PING
  const periodicDurationToPing = Duration(seconds: 3);

  ///Type: Duration
  ///IS DURATION OF TIME TO RECONNECT THE WEBSOCKET
  const reconnectIn = Duration(seconds: 3);

  ///Type: bool (or a function with bool value)
  ///IS A CUSTOM VALIDATION TO CONNECT THE WEBSOCKET
  bool validateIfCanMakeConnection() {
    return true;
  }

  final webSocketConnection = await WebsocketPingValidator.connectWebSocket(url,
      onMessage: (message) async {
    ///MESSAGE RECEIVED FROM SERVER
  }, onConnected: (dateTimeConnected) async {
    ///WEBSOCKET CONNECTED (YOU RECEIVE THE SPECIFIC DateTime WHEN THE CONNECTION OCCURRED)
  }, onConnectionClosed: (statusCode) async {
    ///WEBSOCKET DISCONNECTED (YOU RECEIVE THE SPECIFIC StatusCode IN int WHEN THE DISCONNECTION OCCURRED)
  }, onConnectionLost: () async {
    ///WEBSOCKET HAVE LOST THEIR CONNECTION
  }, onError: (error) async {
    ///WEBSOCKET HAVE OCCURRED AN ERROR (YOU RECEIVED IT)
  }, onReconnectStarted: (duration) async {
    ///FUNCTION BEFORE START RECONNECTION COUNT DOWN
  },
      maxAttempts: maxAttempts,
      periodicDurationToPing: periodicDurationToPing,
      reconnectIn: reconnectIn,
      reconnectOnError: reconnectOnError,
      dataToSendAsPing: dataToSendAsPing,
      validateIfCanMakeConnection: validateIfCanMakeConnection());

  ///YOU CAN CLOSE THE CONNECTION OR OPEN MORE
  await webSocketConnection.close();
}
