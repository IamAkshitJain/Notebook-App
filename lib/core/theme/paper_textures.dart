import 'package:flutter/material.dart';

enum PaperPattern {
  blank,
  lined,
  grid,
  dotGrid,
  cornells,
  blueprint,
  musicStaff,
}

enum PaperColorTheme {
  creamSepia,
  pureWhite,
  warmIvory,
  darkBlueprint,
  darkGraphite,
}

class PaperStyle {
  final PaperPattern pattern;
  final PaperColorTheme colorTheme;
  final double lineSpacing;
  final double gridSpacing;
  final double marginWidth;

  const PaperStyle({
    this.pattern = PaperPattern.lined,
    this.colorTheme = PaperColorTheme.creamSepia,
    this.lineSpacing = 32.0,
    this.gridSpacing = 28.0,
    this.marginWidth = 80.0,
  });

  PaperStyle copyWith({
    PaperPattern? pattern,
    PaperColorTheme? colorTheme,
    double? lineSpacing,
    double? gridSpacing,
    double? marginWidth,
  }) {
    return PaperStyle(
      pattern: pattern ?? this.pattern,
      colorTheme: colorTheme ?? this.colorTheme,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      gridSpacing: gridSpacing ?? this.gridSpacing,
      marginWidth: marginWidth ?? this.marginWidth,
    );
  }
}
