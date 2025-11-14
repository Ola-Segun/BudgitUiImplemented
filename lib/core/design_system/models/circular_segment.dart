import 'package:flutter/material.dart';

/// Represents a single segment in the circular indicator
class CircularSegment {
  const CircularSegment({
    required this.id,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.category,
    required this.budget,
  });

  final String id;
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  final String? category;
  final double budget;

  /// Calculate percentage of total
  double getPercentage(double total) {
    return total > 0 ? (value / total) : 0.0;
  }

  /// Get sweep angle in radians
  double getSweepAngle(double total) {
    return getPercentage(total) * 2 * 3.141592653589793;
  }

  CircularSegment copyWith({
    String? id,
    String? label,
    double? value,
    Color? color,
    IconData? icon,
    String? category,
    double? budget,
  }) {
    return CircularSegment(
      id: id ?? this.id,
      label: label ?? this.label,
      value: value ?? this.value,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      budget: budget ?? this.budget,
    );
  }
}

/// Configuration for segment interaction
class SegmentInteractionConfig {
  const SegmentInteractionConfig({
    this.scaleOnTap = 1.08,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showLabelOnTap = true,
    this.hapticFeedback = true,
    this.glowIntensity = 0.4,
  });

  final double scaleOnTap;
  final Duration animationDuration;
  final bool showLabelOnTap;
  final bool hapticFeedback;
  final double glowIntensity;
}