import 'package:flutter/material.dart';

/// Single sample point in a stroke with pressure and hardware sensor metadata
class TouchPoint {
  final double x;
  final double y;
  final double pressure; // 0.0 to 1.0 (default 0.5 for mouse/finger)
  final double tiltAngle; // Stylus tilt in radians
  final int timestamp; // Milliseconds since epoch

  const TouchPoint({
    required this.x,
    required this.y,
    this.pressure = 0.5,
    this.tiltAngle = 0.0,
    required this.timestamp,
  });

  Offset toOffset() => Offset(x, y);

  TouchPoint copyWith({
    double? x,
    double? y,
    double? pressure,
    double? tiltAngle,
    int? timestamp,
  }) {
    return TouchPoint(
      x: x ?? this.x,
      y: y ?? this.y,
      pressure: pressure ?? this.pressure,
      tiltAngle: tiltAngle ?? this.tiltAngle,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'pressure': pressure,
        'tiltAngle': tiltAngle,
        'timestamp': timestamp,
      };

  factory TouchPoint.fromJson(Map<String, dynamic> json) => TouchPoint(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        pressure: (json['pressure'] as num?)?.toDouble() ?? 0.5,
        tiltAngle: (json['tiltAngle'] as num?)?.toDouble() ?? 0.0,
        timestamp: (json['timestamp'] as num).toInt(),
      );
}
