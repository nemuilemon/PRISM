import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism/core/theme/app_theme.dart';
import 'package:prism/domain/entities/asset.dart';
import 'package:prism/domain/entities/recurring_transaction.dart';
import 'package:prism/presentation/controllers/account_list_controller.dart';
import 'package:prism/presentation/controllers/category_list_controller.dart';
import 'package:prism/presentation/controllers/recurring_transaction_list_controller.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_button.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';

class AddRecurringTransactionPage extends ConsumerStatefulWidget {
  const AddRecurringTransactionPage({this.transaction, super.key});

  final RecurringTransaction? transaction;

  @override
  ConsumerState<AddRecurringTransactionPage> createState() =>
      _AddRecurringTransactionPageState();
}

class _AddRecurringTransactionPageState
    extends ConsumerState<AddRecurringTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dayController = TextEditingController();

  String _type = 'expense';
  int? _categoryId;
  int? _accountId;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _amountController.text = t.amount.toInt().toString();
      _noteController.text = t.note ?? '';
      _dayController.text = t.dayOfMonth.toString();
      _type = t.type;
      _categoryId = t.categoryId;
      _accountId = t.accountId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListControllerProvider);
    final accountsAsync = ref.watch(accountListControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.baseColor,
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? '定期支出の追加' : '定期支出の編集',
          style: const TextStyle(color: AppTheme.textColor),
        ),
        backgroundColor: AppTheme.baseColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              NeumorphicContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Type Selection
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('支出'),
                              value: 'expense',
                              groupValue: _type,
                              onChanged: (val) {
                                if (val != null) setState(() => _type = val);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('収入'),
                              value: 'income',
                              groupValue: _type,
                              onChanged: (val) {
                                if (val != null) setState(() => _type = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Day
                      TextFormField(
                        controller: _dayController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '毎月の日付 (1-31)',
                          helperText: '月末日は自動調整されません(31指定で30日の月は実行されません)',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '日付を入力してください';
                          }
                          final day = int.tryParse(value);
                          if (day == null || day < 1 || day > 31) {
                            return '1から31の間で入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Amount
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '金額'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '金額を入力してください';
                          }
                          if (double.tryParse(value) == null) {
                            return '有効な数値を入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      categoriesAsync.when(
                        data: (categories) {
                          final filtered = categories
                              .where((c) => c.type == _type)
                              .toList();
                          return DropdownButtonFormField<int>(
                            value: _categoryId,
                            decoration: const InputDecoration(
                              labelText: 'カテゴリ',
                            ),
                            items: filtered.map((c) {
                              return DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _categoryId = val),
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('カテゴリ読み込みエラー'),
                      ),
                      // Account
                      accountsAsync.when(
                        data: (accounts) {
                          if (accounts.isNotEmpty && _accountId == null) {
                            _accountId = int.tryParse(accounts.first.id);
                          }
                          return DropdownButtonFormField<int>(
                            value: _accountId,
                            decoration: const InputDecoration(labelText: '口座'),
                            items: accounts
                                .map((a) {
                                  final name = a.map(
                                    financial: (v) => v.name,
                                    point: (v) => v.providerName,
                                    experience: (v) => v.activityName,
                                  );
                                  final id = int.tryParse(a.id);

                                  if (id == null) {
                                    return const DropdownMenuItem<int>(
                                      value: -1,
                                      child: Text('Invalid ID'),
                                    );
                                  }

                                  return DropdownMenuItem<int>(
                                    value: id,
                                    child: Text(name),
                                  );
                                })
                                .where((item) => item.value != -1)
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _accountId = val),
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('口座読み込みエラー'),
                      ),
                      const SizedBox(height: 16),

                      // Note
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(labelText: 'メモ'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: NeumorphicButton(
                  onPressed: _save,
                  child: const Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_accountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('口座を選択してください')),
        );
        return;
      }

      final amount = double.parse(_amountController.text);
      final day = int.parse(_dayController.text);

      try {
        if (widget.transaction == null) {
          await ref
              .read(recurringTransactionListControllerProvider.notifier)
              .addRecurringTransaction(
                accountId: _accountId!,
                amount: amount,
                dayOfMonth: day,
                categoryId: _categoryId,
                note: _noteController.text,
                type: _type,
              );
        } else {
          final updated = widget.transaction!.copyWith(
            accountId: _accountId!,
            amount: amount,
            dayOfMonth: day,
            categoryId: _categoryId,
            note: _noteController.text,
            type: _type,
          );
          await ref
              .read(recurringTransactionListControllerProvider.notifier)
              .updateRecurringTransaction(updated);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラー: $e')),
          );
        }
      }
    }
  }
}
