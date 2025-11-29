import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'data/datasources/local/app_database.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'presentation/pages/account_list_page.dart';
import 'presentation/pages/transaction/transaction_list_page.dart';
import 'presentation/pages/settings/settings_page.dart';

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
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const TransactionListPage(),
    const AccountListPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Asset Manager',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'ダッシュボード',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: '取引',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: '口座',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
          backgroundColor: AppTheme.baseColor,
          selectedItemColor: AppTheme.accentColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
