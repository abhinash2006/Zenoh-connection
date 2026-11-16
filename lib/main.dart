import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/telemetry_service.dart';
import 'ui/dashboard.dart';

// ==========================================
// CONFIGURATION TOGGLE
// Set to 'false' when Jetson Nano is online.
// ==========================================
const bool isMockMode = false;

void main() {
  // Initialize the correct architecture implementation
  final TelemetryService telemetryService = isMockMode
      ? MockTelemetryService()
      : ZenohTelemetryService(
          routerUrl: 'http://10.133.10.101:8000', // Localhost for fake Zenoh server or update to Jetson IP
          keyPath: 'neerdrishtiy/telemetry',
        );

  runApp(
    MultiProvider(
      providers: [
        Provider<TelemetryService>.value(value: telemetryService),
        StreamProvider<String?>( // Changed from WaterQualityData? to String?
          create: (_) => telemetryService.telemetryStream,
          initialData: null,
          catchError: (_, error) {
            print("Stream Provider Error: $error");
            return null;
          },
        ),
      ],
      child: const NeerDrishtiyApp(),
    ),
  );
}

class NeerDrishtiyApp extends StatelessWidget {
  const NeerDrishtiyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeerDrishtiy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: const DashboardScreen(isMockMode: isMockMode),
    );
  }
}