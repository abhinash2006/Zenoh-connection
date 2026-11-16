class WaterQualityData {
  final double ph;
  final double tds;
  final double turbidity;
  final int microplastics;
  final DateTime timestamp;

  WaterQualityData({
    required this.ph,
    required this.tds,
    required this.turbidity,
    required this.microplastics,
    required this.timestamp,
  });

  factory WaterQualityData.fromJson(Map<String, dynamic> json) {
    return WaterQualityData(
      ph: (json['ph'] ?? 0.0).toDouble(),
      tds: (json['tds'] ?? 0.0).toDouble(),
      turbidity: (json['turbidity'] ?? 0.0).toDouble(),
      microplastics: (json['microplastics'] ?? 0).toInt(),
      timestamp: DateTime.now(),
    );
  }
}