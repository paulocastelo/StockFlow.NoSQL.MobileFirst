# StockFlow Mobile

Flutter mobile app for `StockFlow.Core`, focused on field operators who need to:

- sign in with an existing account
- inspect products and current stock balance
- review stock movement history
- register stock entries and exits

## Prerequisites

- Flutter SDK `>= 3.x`
- Android Emulator or physical device
- Local `StockFlow.Core` backend running

## Backend URL configuration

Set the backend base URL in `lib/core/constants.dart`.

Default value:

```dart
static const String apiBaseUrl = 'http://10.0.2.2:5000';
```

Notes:

- Android Emulator: use `10.0.2.2`
- Physical device: use your machine IP on the local network

## How to run

```bash
flutter pub get
flutter run
```
