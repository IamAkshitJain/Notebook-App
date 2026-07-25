import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local_storage_datasource.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/notebook_provider.dart';
import 'presentation/views/notebook_editor_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Hive Database
  final localDs = LocalStorageDatasource();
  await localDs.init();

  runApp(
    const ProviderScope(
      child: PaperCraftApp(),
    ),
  );
}

class PaperCraftApp extends ConsumerWidget {
  const PaperCraftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'PaperCraft Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const NotebookEditorView(),
    );
  }
}
