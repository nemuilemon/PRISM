import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'data/datasources/local/app_database.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/account_list_page.dart';
import 'presentation/widgets/neumorphism/neumorphic_button.dart';

part 'main.g.dart';

// データベースインスタンスのプロバイダー (報告書 2.2 DI戦略)
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  return AppDatabase();
}

void main() {
  runApp(
    // ProviderScopeでアプリ全体をラップ
    const ProviderScope(
      child: LifeAssetApp(),
    ),
  );
}

// ... (imports)

class LifeAssetApp extends ConsumerWidget {
  const LifeAssetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Life Asset Manager',
      theme: AppTheme.lightTheme,
      home: const AccountListPage(),
    );
  }
}

class NeumorphicButtonDemo extends StatelessWidget {
  const NeumorphicButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: () {
        debugPrint('Button Pressed');
      },
      child: const Text(
        'Neumorphic Button',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textColor,
        ),
      ),
    );
  }
}
