import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism/core/theme/app_theme.dart';
import 'package:prism/domain/entities/category.dart';
import 'package:prism/presentation/controllers/category_list_controller.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_button.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';

class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.baseColor,
      appBar: AppBar(
        title: const Text(
          'カテゴリ管理',
          style: TextStyle(color: AppTheme.textColor),
        ),
        backgroundColor: AppTheme.baseColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('カテゴリがありません'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NeumorphicContainer(
                  child: ListTile(
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      category.type == 'income' ? '収入' : '支出',
                      style: TextStyle(
                        color: category.type == 'income'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppTheme.accentColor,
                          ),
                          onPressed: () =>
                              _showCategoryDialog(context, ref, category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _confirmDelete(context, ref, category.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: NeumorphicButton(
        onPressed: () => _showCategoryDialog(context, ref, null),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Icon(Icons.add, color: AppTheme.accentColor),
        ),
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Category? category,
  ) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    var type = category?.type ?? 'expense';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(category == null ? 'カテゴリ追加' : 'カテゴリ編集'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'カテゴリ名'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('支出'),
                          value: 'expense',
                          groupValue: type,
                          onChanged: (value) => setState(() => type = value!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('収入'),
                          value: 'income',
                          groupValue: type,
                          onChanged: (value) => setState(() => type = value!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      if (category == null) {
                        await ref
                            .read(categoryListControllerProvider.notifier)
                            .addCategory(nameController.text, type);
                      } else {
                        await ref
                            .read(categoryListControllerProvider.notifier)
                            .updateCategory(
                              category.copyWith(
                                name: nameController.text,
                                type: type,
                              ),
                            );
                      }
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: const Text('このカテゴリを削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(categoryListControllerProvider.notifier)
                  .deleteCategory(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
