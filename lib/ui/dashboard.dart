import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  final bool isMockMode;

  const DashboardScreen({Key? key, required this.isMockMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listens to the StreamProvider automatically for a String type now
    final message = context.watch<String?>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('NeerDrishtiy String Tester', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildConnectionBanner(),
          Expanded(
            child: message == null
                ? _buildLoadingState()
                : _buildMessageDisplay(message),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.teal),
          SizedBox(height: 16),
          Text('Awaiting Zenoh Stream...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildConnectionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isMockMode ? Colors.orange.shade800 : Colors.teal.shade700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isMockMode ? Icons.science : Icons.wifi_tethering,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isMockMode ? 'MOCK STRING ACTIVE' : 'ZENOH LIVE CONNECTION',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageDisplay(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          color: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.message, size: 48, color: Colors.tealAccent),
                const SizedBox(height: 24),
                const Text(
                  "LATEST RAW PAYLOAD",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}