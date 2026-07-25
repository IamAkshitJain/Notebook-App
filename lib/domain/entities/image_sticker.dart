import 'package:flutter/material.dart';

class ImageSticker {
  final String id;
  final String imagePath; // Local path or URL
  final Offset position;
  final Size size;
  final double rotation; // Radians
  final bool isSelected;

  const ImageSticker({
    required this.id,
    required this.imagePath,
    this.position = const Offset(100, 100),
    this.size = const Size(200, 200),
    this.rotation = 0.0,
    this.isSelected = false,
  });

  ImageSticker copyWith({
    String? id,
    String? imagePath,
    Offset? position,
    Size? size,
    double? rotation,
    bool? isSelected,
  }) {
    return ImageSticker(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'positionX': position.dx,
        'positionY': position.dy,
        'width': size.width,
        'height': size.height,
        'rotation': rotation,
      };

  factory ImageSticker.fromJson(Map<String, dynamic> json) => ImageSticker(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String,
        position: Offset(
          (json['positionX'] as num).toDouble(),
          (json['positionY'] as num).toDouble(),
        ),
        size: Size(
          (json['width'] as num).toDouble(),
          (json['height'] as num).toDouble(),
        ),
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      );
}
