import '../../core/theme/paper_textures.dart';
import 'stroke.dart';
import 'image_sticker.dart';

class NotebookPage {
  final String id;
  final int pageIndex;
  final PaperStyle paperStyle;
  final List<Stroke> strokes;
  final List<ImageSticker> imageStickers;
  final bool isBookmarked;
  final String? cachedThumbnailPath;
  final int lastModified;

  NotebookPage({
    required this.id,
    required this.pageIndex,
    this.paperStyle = const PaperStyle(),
    List<Stroke>? strokes,
    List<ImageSticker>? imageStickers,
    this.isBookmarked = false,
    this.cachedThumbnailPath,
    int? lastModified,
  })  : strokes = strokes ?? [],
        imageStickers = imageStickers ?? [],
        lastModified = lastModified ?? DateTime.now().millisecondsSinceEpoch;

  NotebookPage copyWith({
    String? id,
    int? pageIndex,
    PaperStyle? paperStyle,
    List<Stroke>? strokes,
    List<ImageSticker>? imageStickers,
    bool? isBookmarked,
    String? cachedThumbnailPath,
    int? lastModified,
  }) {
    return NotebookPage(
      id: id ?? this.id,
      pageIndex: pageIndex ?? this.pageIndex,
      paperStyle: paperStyle ?? this.paperStyle,
      strokes: strokes ?? this.strokes,
      imageStickers: imageStickers ?? this.imageStickers,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      cachedThumbnailPath: cachedThumbnailPath ?? this.cachedThumbnailPath,
      lastModified: lastModified ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pageIndex': pageIndex,
        'pattern': paperStyle.pattern.index,
        'colorTheme': paperStyle.colorTheme.index,
        'lineSpacing': paperStyle.lineSpacing,
        'gridSpacing': paperStyle.gridSpacing,
        'marginWidth': paperStyle.marginWidth,
        'strokes': strokes.map((s) => s.toJson()).toList(),
        'imageStickers': imageStickers.map((i) => i.toJson()).toList(),
        'isBookmarked': isBookmarked,
        'lastModified': lastModified,
      };

  factory NotebookPage.fromJson(Map<String, dynamic> json) => NotebookPage(
        id: json['id'] as String,
        pageIndex: json['pageIndex'] as int,
        paperStyle: PaperStyle(
          pattern: PaperPattern.values[json['pattern'] as int? ?? 1],
          colorTheme: PaperColorTheme.values[json['colorTheme'] as int? ?? 0],
          lineSpacing: (json['lineSpacing'] as num?)?.toDouble() ?? 32.0,
          gridSpacing: (json['gridSpacing'] as num?)?.toDouble() ?? 28.0,
          marginWidth: (json['marginWidth'] as num?)?.toDouble() ?? 80.0,
        ),
        strokes: (json['strokes'] as List? ?? [])
            .map((s) => Stroke.fromJson(s as Map<String, dynamic>))
            .toList(),
        imageStickers: (json['imageStickers'] as List? ?? [])
            .map((i) => ImageSticker.fromJson(i as Map<String, dynamic>))
            .toList(),
        isBookmarked: json['isBookmarked'] as bool? ?? false,
        lastModified: json['lastModified'] as int? ?? 0,
      );
}
