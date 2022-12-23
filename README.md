# sql_data_helper

[![pub package](https://img.shields.io/pub/v/websocket_ping_validator.svg)](https://pub.dev/packages/websocket_ping_validator)

A dart package to use websockets and check the connection.

## Getting Started

### Installing

In your Flutter project, add the package to your dependencies

`flutter pub add websocket_ping_validator`

or

```yml
dependencies:
  ...
  websocket_ping_validator: #last_version
  ...
```

## Usage Example

```dart
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

  await WebsocketPingValidator.connectWebSocket(url,
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
}
```