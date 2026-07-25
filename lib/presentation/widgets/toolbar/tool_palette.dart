import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/drawing_tool.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/canvas_state_provider.dart';

class ToolPalette extends ConsumerWidget {
  const ToolPalette({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasStateProvider);
    final canvasNotifier = ref.read(canvasStateProvider.notifier);
    final activeTool = canvasState.activeTool;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fountain Pen
          _buildToolButton(
            context,
            icon: Icons.edit_rounded,
            label: 'Fountain Pen',
            isSelected: activeTool.type == ToolType.fountainPen,
            onTap: () => canvasNotifier.setToolType(ToolType.fountainPen),
          ),

          // Ballpoint Pen
          _buildToolButton(
            context,
            icon: Icons.border_color_rounded,
            label: 'Ballpoint',
            isSelected: activeTool.type == ToolType.ballpointPen,
            onTap: () => canvasNotifier.setToolType(ToolType.ballpointPen),
          ),

          // Highlighter
          _buildToolButton(
            context,
            icon: Icons.highlight_rounded,
            label: 'Highlighter',
            isSelected: activeTool.type == ToolType.highlighter,
            onTap: () => canvasNotifier.setToolType(ToolType.highlighter),
          ),

          // Eraser
          _buildToolButton(
            context,
            icon: Icons.cleaning_services_rounded,
            label: 'Stroke Eraser',
            isSelected: activeTool.type == ToolType.strokeEraser,
            onTap: () => canvasNotifier.setToolType(ToolType.strokeEraser),
          ),

          // Lasso Selection
          _buildToolButton(
            context,
            icon: Icons.select_all_rounded,
            label: 'Lasso Tool',
            isSelected: activeTool.type == ToolType.lasso,
            onTap: () => canvasNotifier.setToolType(ToolType.lasso),
          ),

          // Auto Shapes
          _buildToolButton(
            context,
            icon: Icons.interests_rounded,
            label: 'Auto Shapes',
            isSelected: activeTool.type == ToolType.shapes,
            onTap: () => canvasNotifier.setToolType(ToolType.shapes),
          ),

          const SizedBox(width: 12),
          Container(height: 24, width: 1, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(width: 12),

          // Ink Color Swatches
          ...AppColors.defaultInkColors.take(5).map((color) {
            final isSelected = activeTool.color == color;
            return GestureDetector(
              onTap: () => canvasNotifier.setToolColor(color),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
                      : Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                ),
              ),
            );
          }),

          const SizedBox(width: 12),

          // Stroke Width Selector Slider Preview
          SizedBox(
            width: 90,
            child: Slider(
              value: activeTool.width,
              min: 1.0,
              max: 20.0,
              onChanged: (val) => canvasNotifier.setToolWidth(val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected ? primary : Theme.of(context).iconTheme.color,
            size: 20,
          ),
        ),
      ),
    );
  }
}
