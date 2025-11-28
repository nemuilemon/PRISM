import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'data/datasources/local/app_database.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/account_list_page.dart';
import 'presentation/pages/transaction/transaction_list_page.dart';

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

class LifeAssetApp extends ConsumerStatefulWidget {
  const LifeAssetApp({super.key});

  @override
  ConsumerState<LifeAssetApp> createState() => _LifeAssetAppState();
}

class _LifeAssetAppState extends ConsumerState<LifeAssetApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TransactionListPage(),
    const AccountListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Asset Manager',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: '取引一覧',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: '口座一覧',
            ),
          ],
          backgroundColor: AppTheme.baseColor,
          selectedItemColor: AppTheme.accentColor,
          unselectedItemColor: AppTheme.textColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
