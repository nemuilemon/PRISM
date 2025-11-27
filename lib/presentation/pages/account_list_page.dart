import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/account_list_controller.dart';
import '../widgets/neumorphism/neumorphic_container.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local/app_database.dart' as db;

class AccountListPage extends ConsumerWidget {
  const AccountListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountListAsync = ref.watch(accountListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: accountListAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('No accounts yet. Add one!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index] as db.Account;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NeumorphicContainer(
                  child: ListTile(
                    title: Text(
                      account.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    subtitle: Text('${account.type} - ${account.currencyCode}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final typeController = TextEditingController(text: 'Cash');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Account Name'),
            ),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Type (e.g. Bank, Cash)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref
                    .read(accountListControllerProvider.notifier)
                    .addAccount(nameController.text, typeController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
