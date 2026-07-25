import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/pdf_exporter.dart';
import '../providers/canvas_state_provider.dart';
import '../providers/notebook_provider.dart';
import '../widgets/canvas/paper_background_painter.dart';
import '../widgets/canvas/stroke_painter.dart';
import '../widgets/canvas/image_sticker_widget.dart';
import '../widgets/toolbar/top_toolbar.dart';
import '../widgets/toolbar/tool_palette.dart';
import '../widgets/sidebar/notebook_drawer.dart';
import '../widgets/sidebar/page_thumbnail_bar.dart';
import '../widgets/dialogs/text_to_handwriting_dialog.dart';
import '../widgets/dialogs/gemini_ai_dialog.dart';
import '../widgets/dialogs/create_notebook_dialog.dart';

class NotebookEditorView extends ConsumerStatefulWidget {
  const NotebookEditorView({Key? key}) : super(key: key);

  @override
  ConsumerState<NotebookEditorView> createState() => _NotebookEditorViewState();
}

class _NotebookEditorViewState extends ConsumerState<NotebookEditorView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showPageThumbnails = false;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasStateProvider);
    final canvasNotifier = ref.read(canvasStateProvider.notifier);
    final notebookState = ref.watch(notebookProvider);
    final notebookNotifier = ref.read(notebookProvider.notifier);

    final activeNotebook = notebookState.activeNotebook;
    final activePage = (activeNotebook != null &&
            activeNotebook.pages.isNotEmpty &&
            notebookState.activePageIndex < activeNotebook.pages.length)
        ? activeNotebook.pages[notebookState.activePageIndex]
        : null;

    return Scaffold(
      key: _scaffoldKey,
      drawer: NotebookDrawer(
        onCreateNewNotebook: () {
          showDialog(
            context: context,
            builder: (context) => const CreateNotebookDialog(),
          );
        },
      ),
      appBar: TopToolbar(
        onOpenSidebar: () => _scaffoldKey.currentState?.openDrawer(),
        onOpenGeminiDialog: () {
          showDialog(
            context: context,
            builder: (context) => const GeminiAiDialog(),
          );
        },
        onOpenTextToHandwritingDialog: () {
          showDialog(
            context: context,
            builder: (context) => const TextToHandwritingDialog(),
          );
        },
        onExportPdf: () async {
          if (activeNotebook == null) return;
          final pdfBytes = await PdfExporter.buildNotebookPdf(activeNotebook);
          await Printing.sharePdf(bytes: pdfBytes, filename: '${activeNotebook.title}.pdf');
        },
      ),
      body: activePage == null
          ? const Center(child: Text('No active page selected'))
          : Row(
              children: [
                // Main Interactive Paper Canvas Workspace
                Expanded(
                  child: Stack(
                    children: [
                      // Scrollable and Zoomable Paper Page Container
                      InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 3.5,
                        boundaryMargin: const EdgeInsets.all(400),
                        child: Center(
                          child: Container(
                            width: AppConfig.defaultPageWidth,
                            height: AppConfig.defaultPageHeight,
                            margin: const EdgeInsets.symmetric(vertical: 30),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // 1. Realistic Paper Texture & Ruled Line Background
                                CustomPaint(
                                  size: const Size(
                                    AppConfig.defaultPageWidth,
                                    AppConfig.defaultPageHeight,
                                  ),
                                  painter: PaperBackgroundPainter(
                                    style: activePage.paperStyle,
                                  ),
                                ),

                                // 2. Image Stickers Overlay
                                ...activePage.imageStickers.map(
                                  (sticker) => ImageStickerWidget(
                                    sticker: sticker,
                                    onUpdate: (updated) {},
                                    onDelete: () {},
                                  ),
                                ),

                                // 3. Touch Gesture & Stylus Ink Drawing Canvas
                                Listener(
                                  onPointerDown: (event) {
                                    canvasNotifier.onPointerDown(
                                      event.localPosition,
                                      event.pressure > 0 ? event.pressure : 0.5,
                                    );
                                  },
                                  onPointerMove: (event) {
                                    canvasNotifier.onPointerMove(
                                      event.localPosition,
                                      event.pressure > 0 ? event.pressure : 0.5,
                                    );
                                  },
                                  onPointerUp: (event) {
                                    canvasNotifier.onPointerUp();
                                    // Auto-save strokes to active notebook page
                                    final updatedPage = activePage.copyWith(
                                      strokes: ref.read(canvasStateProvider).strokes,
                                    );
                                    notebookNotifier.saveCurrentPageStrokes(updatedPage);
                                  },
                                  child: CustomPaint(
                                    size: const Size(
                                      AppConfig.defaultPageWidth,
                                      AppConfig.defaultPageHeight,
                                    ),
                                    painter: StrokePainter(
                                      strokes: canvasState.strokes,
                                      currentDrawingStroke: canvasState.currentDrawingStroke,
                                      lassoSelectionRect: canvasState.lassoSelectionRect,
                                      selectedStrokes: canvasState.selectedStrokes,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Floating Pen Tool Palette Bar (Goodnotes Style Bottom Dock)
                      const Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ToolPalette(),
                        ),
                      ),

                      // Toggle Page Thumbnail Bar Button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          heroTag: 'toggle_thumbnail',
                          child: Icon(showPageThumbnails ? Icons.close_rounded : Icons.grid_view_rounded),
                          onPressed: () {
                            setState(() => showPageThumbnails = !showPageThumbnails);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Collapsible Page Thumbnail Bar on the Right
                if (showPageThumbnails) const PageThumbnailBar(),
              ],
            ),
    );
  }
}
