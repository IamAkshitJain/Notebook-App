import 'package:flutter/material.dart';
import '../../../domain/entities/image_sticker.dart';

class ImageStickerWidget extends StatefulWidget {
  final ImageSticker sticker;
  final Function(ImageSticker updated) onUpdate;
  final VoidCallback onDelete;

  const ImageStickerWidget({
    Key? key,
    required this.sticker,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ImageStickerWidget> createState() => _ImageStickerWidgetState();
}

class _ImageStickerWidgetState extends State<ImageStickerWidget> {
  late Offset position;
  late Size size;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    position = widget.sticker.position;
    size = widget.sticker.size;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() => isSelected = !isSelected);
        },
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
          widget.onUpdate(widget.sticker.copyWith(position: position));
        },
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  widget.sticker.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.blueGrey.withOpacity(0.2),
                      child: const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.blueGrey),
                      ),
                    );
                  },
                ),
              ),
              if (isSelected)
                Positioned(
                  right: 4,
                  top: 4,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: widget.onDelete,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
