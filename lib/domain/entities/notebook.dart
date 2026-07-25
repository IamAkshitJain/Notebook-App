import 'page.dart';

class Notebook {
  final String id;
  final String title;
  final String categoryFolder;
  final int coverColorValue;
  final String coverPatternName;
  final List<NotebookPage> pages;
  final int createdAt;
  final int updatedAt;
  final bool isSyncedToCloud;

  Notebook({
    required this.id,
    required this.title,
    this.categoryFolder = 'General',
    this.coverColorValue = 0xFF6C5CE7,
    this.coverPatternName = 'Leather',
    List<NotebookPage>? pages,
    int? createdAt,
    int? updatedAt,
    this.isSyncedToCloud = false,
  })  : pages = pages ?? [NotebookPage(id: '${id}_page_1', pageIndex: 0)],
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  Notebook copyWith({
    String? id,
    String? title,
    String? categoryFolder,
    int? coverColorValue,
    String? coverPatternName,
    List<NotebookPage>? pages,
    int? createdAt,
    int? updatedAt,
    bool? isSyncedToCloud,
  }) {
    return Notebook(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryFolder: categoryFolder ?? this.categoryFolder,
      coverColorValue: coverColorValue ?? this.coverColorValue,
      coverPatternName: coverPatternName ?? this.coverPatternName,
      pages: pages ?? this.pages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().millisecondsSinceEpoch,
      isSyncedToCloud: isSyncedToCloud ?? this.isSyncedToCloud,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'categoryFolder': categoryFolder,
        'coverColorValue': coverColorValue,
        'coverPatternName': coverPatternName,
        'pages': pages.map((p) => p.toJson()).toList(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'isSyncedToCloud': isSyncedToCloud,
      };

  factory Notebook.fromJson(Map<String, dynamic> json) => Notebook(
        id: json['id'] as String,
        title: json['title'] as String,
        categoryFolder: json['categoryFolder'] as String? ?? 'General',
        coverColorValue: json['coverColorValue'] as int? ?? 0xFF6C5CE7,
        coverPatternName: json['coverPatternName'] as String? ?? 'Leather',
        pages: (json['pages'] as List? ?? [])
            .map((p) => NotebookPage.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] as int? ?? 0,
        updatedAt: json['updatedAt'] as int? ?? 0,
        isSyncedToCloud: json['isSyncedToCloud'] as bool? ?? false,
      );
}
