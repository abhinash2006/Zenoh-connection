import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class TelemetryService {
  Stream<String> get telemetryStream;
  void dispose();
}

/// Phase 1: Local Testing / Mock Mode
class MockTelemetryService implements TelemetryService {
  final _controller = StreamController<String>.broadcast();
  Timer? _timer;
  int _counter = 1;

  MockTelemetryService() {
    // Generates a mock string every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _controller.add("Mock Hello World - Message #$_counter");
      _counter++;
    });
  }

  @override
  Stream<String> get telemetryStream => _controller.stream;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

/// Phase 2: Live Zenoh Integration via REST / SSE
class ZenohTelemetryService implements TelemetryService {
  final String routerUrl; // e.g., http://192.168.1.50:8000
  final String keyPath;   // e.g., neerdrishtiy/telemetry

  final _controller = StreamController<String>.broadcast();
  http.Client? _client;
  bool _isDisposed = false;

  ZenohTelemetryService({required this.routerUrl, required this.keyPath}) {
    _connectToZenohSSE();
  }

  void _connectToZenohSSE() async {
    if (_isDisposed) return;
    _client = http.Client();

    try {
      final request = http.Request('GET', Uri.parse('$routerUrl/$keyPath'));
      // Using text/event-stream forces the Zenoh REST plugin into Pub/Sub Mode
      request.headers['Accept'] = 'text/event-stream';

      final response = await _client!.send(request);

      if (response.statusCode == 200) {
        response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((line) {
          if (line.startsWith('data: ')) {
            try {
              final String dataStr = line.substring(6);
              final Map<String, dynamic> payload = jsonDecode(dataStr);

              // Zenoh wraps published data in a "value" key.
              // The REST plugin often base64-encodes this value.
              final dynamic val = payload['value'];
              String resultStr = val.toString();

              try {
                // Attempt to decode if it is base64 encoded
                final bytes = base64.decode(resultStr);
                resultStr = utf8.decode(bytes);
              } catch (e) {
                // If it fails to decode, fallback to the original string
              }

              _controller.add(resultStr);
            } catch (e) {
              // If JSON parsing fails (e.g. raw string stream without wrappers),
              // fallback to passing the raw line content
              print('JSON Parse Error, defaulting to raw string: $e');
              _controller.add(line.substring(6));
            }
          }
        }, onError: (error) {
          print('Zenoh Stream Error: $error');
          _retryConnection();
        }, onDone: () {
          _retryConnection();
        });
      } else {
         print('Zenoh Connection Failed with status: ${response.statusCode}');
         _retryConnection();
      }
    } catch (e) {
      print('Zenoh Exception: $e');
      _retryConnection();
    }
  }

  void _retryConnection() {
     if (_isDisposed) return;
     _client?.close();
     Future.delayed(const Duration(seconds: 3), () {
       _connectToZenohSSE(); // Auto-reconnect loop
     });
  }

  @override
  Stream<String> get telemetryStream => _controller.stream;

  @override
  void dispose() {
    _isDisposed = true;
    _client?.close();
    _controller.close();
  }
}