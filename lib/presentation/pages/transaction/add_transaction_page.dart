import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism/core/theme/app_theme.dart';
import 'package:prism/domain/entities/asset.dart';
import 'package:prism/domain/entities/transaction.dart';
import 'package:prism/presentation/controllers/account_list_controller.dart';
import 'package:prism/presentation/controllers/category_list_controller.dart';
import 'package:prism/presentation/controllers/transaction_list_controller.dart';
import 'package:prism/presentation/widgets/input/calculator_keyboard.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_button.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key, this.transaction});

  final Transaction? transaction;

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedAccountId;
  int? _selectedCategoryId;
  bool _isInvestment = false;
  int _emotionalScore = 0;
  String _type = 'expense'; // 'income' or 'expense'

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _amountController.text = t.amount.abs().toString(); // 絶対値で表示
      _selectedDate = t.date;
      _selectedAccountId = t.accountId;
      _selectedCategoryId = t.categoryId;
      _noteController.text = t.note ?? '';
      _isInvestment = t.isInvestment;
      _emotionalScore = t.emotionalScore;
      _type = t.type;

      // typeが未設定(古いデータ)の場合、金額の正負で判定
      if (_type == 'expense' && t.amount > 0) {
        if (t.amount > 0) _type = 'income';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountListControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.baseColor,
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? '取引を追加' : '取引を編集',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selector
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = 'expense'),
                      child: NeumorphicContainer(
                        isPressed: _type == 'expense',
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              '支出',
                              style: TextStyle(
                                color: _type == 'expense'
                                    ? Colors.red
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = 'income'),
                      child: NeumorphicContainer(
                        isPressed: _type == 'income',
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              '収入',
                              style: TextStyle(
                                color: _type == 'income'
                                    ? Colors.green
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount
              NeumorphicContainer(
                child: TextFormField(
                  controller: _amountController,
                  readOnly: true,
                  onTap: () async {
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: SafeArea(
                          child: CalculatorKeyboard(
                            initialValue: _amountController.text,
                            onChanged: (value) {
                              _amountController.text = value;
                            },
                            onSubmit: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  decoration: const InputDecoration(
                    labelText: '金額',
                    border: InputBorder.none,
                    prefixText: '¥ ',
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _type == 'expense' ? Colors.red : Colors.green,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '金額を入力してください';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Date
              NeumorphicButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('日付'),
                    Text(_selectedDate.toString().split(' ')[0]),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Account
              accountsAsync.when(
                data: (assets) {
                  if (assets.isEmpty) {
                    return const Text('口座が見つかりません。先に口座を作成してください。');
                  }

                  return NeumorphicContainer(
                    child: DropdownButtonFormField<int>(
                      value: _selectedAccountId,
                      decoration: const InputDecoration(
                        labelText: '口座',
                        border: InputBorder.none,
                      ),
                      items: assets.map((asset) {
                        return DropdownMenuItem(
                          value: int.tryParse(asset.id) ?? -1,
                          child: Text(
                            asset.map(
                              financial: (a) => a.name,
                              point: (a) => a.providerName,
                              experience: (a) => a.activityName,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAccountId = value;
                        });
                      },
                      validator: (value) =>
                          value == null || value == -1 ? '口座を選択してください' : null,
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading accounts: $err'),
              ),
              const SizedBox(height: 20),

              // Category
              Consumer(
                builder: (context, ref, child) {
                  final categoriesAsync = ref.watch(
                    categoryListControllerProvider,
                  );
                  return categoriesAsync.when(
                    data: (categories) {
                      // 現在のタイプ（収入/支出）に合うカテゴリのみフィルタリング
                      final filteredCategories = categories
                          .where((c) => c.type == _type)
                          .toList();

                      return NeumorphicContainer(
                        child: DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'カテゴリ',
                            border: InputBorder.none,
                          ),
                          items: filteredCategories.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        ),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) =>
                        Text('Error loading categories: $err'),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Note
              NeumorphicContainer(
                child: TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'メモ',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Investment Flag
              NeumorphicContainer(
                child: SwitchListTile(
                  title: const Text('自己投資 (資産)'),
                  subtitle: const Text('未来への投資として記録する'),
                  value: _isInvestment,
                  onChanged: (value) {
                    setState(() {
                      _isInvestment = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Emotional Score
              const Text(
                '感情スコア',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('-5'),
                  Expanded(
                    child: Slider(
                      value: _emotionalScore.toDouble(),
                      min: -5,
                      max: 5,
                      divisions: 10,
                      label: _emotionalScore.toString(),
                      onChanged: (value) {
                        setState(() {
                          _emotionalScore = value.toInt();
                        });
                      },
                    ),
                  ),
                  const Text('+5'),
                ],
              ),
              Center(
                child: Text(
                  'スコア: $_emotionalScore',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _emotionalScore > 0
                        ? Colors.green
                        : (_emotionalScore < 0 ? Colors.orange : Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Submit
              SizedBox(
                width: double.infinity,
                child: NeumorphicButton(
                  onPressed: _submit,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      widget.transaction == null ? '保存する' : '更新する',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ),
                ),
              ),

              // Delete Button (Only in Edit Mode)
              if (widget.transaction != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: NeumorphicButton(
                    onPressed: _delete,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '削除する',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('口座を選択してください')),
        );
        return;
      }

      var amount = double.tryParse(_amountController.text) ?? 0;
      // 支出ならマイナス、収入ならプラスにする
      if (_type == 'expense') {
        amount = -amount.abs();
      } else {
        amount = amount.abs();
      }

      if (widget.transaction != null) {
        // Update
        final updatedTransaction = widget.transaction!.copyWith(
          accountId: _selectedAccountId!,
          amount: amount,
          date: _selectedDate,
          categoryId: _selectedCategoryId,
          isInvestment: _isInvestment,
          emotionalScore: _emotionalScore,
          note: _noteController.text,
          type: _type,
        );
        await ref
            .read(transactionListControllerProvider.notifier)
            .updateTransaction(updatedTransaction);
      } else {
        // Add
        await ref
            .read(transactionListControllerProvider.notifier)
            .addTransaction(
              accountId: _selectedAccountId!,
              amount: amount,
              date: _selectedDate,
              categoryId: _selectedCategoryId,
              isInvestment: _isInvestment,
              emotionalScore: _emotionalScore,
              note: _noteController.text,
              type: _type,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _delete() async {
    if (widget.transaction != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('削除の確認'),
          content: const Text('この取引を削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm ?? false) {
        await ref
            .read(transactionListControllerProvider.notifier)
            .deleteTransaction(widget.transaction!.id);
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }
}
