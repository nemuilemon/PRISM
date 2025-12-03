import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism/core/theme/app_theme.dart';
import 'package:prism/domain/entities/asset.dart';
import 'package:prism/presentation/controllers/account_list_controller.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';

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
        data: (assets) {
          if (assets.isEmpty) {
            return const Center(child: Text('No accounts yet. Add one!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NeumorphicContainer(
                  child: ListTile(
                    title: Text(
                      switch (asset) {
                        final FinancialAsset a => a.name,
                        final PointAsset a => a.providerName,
                        final ExperienceAsset a => a.activityName,
                      },
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    subtitle: switch (asset) {
                      final FinancialAsset a => Text(
                        'Financial - ${a.currency} : ${a.amount}',
                      ),
                      final PointAsset a => Text('Point - ${a.points}pt'),
                      final ExperienceAsset a => Text(
                        'Experience - Lv.${a.accumulatedLevel}',
                      ),
                    },
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

  Future<void> _showAddAccountDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    final typeController = TextEditingController(text: 'Cash');

    await showDialog<void>(
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
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await ref
                    .read(accountListControllerProvider.notifier)
                    .addAccount(nameController.text, typeController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
