import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism/core/theme/app_theme.dart';
import 'package:prism/presentation/controllers/account_list_controller.dart';
import 'package:prism/presentation/controllers/transaction_list_controller.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_button.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';
import 'package:prism/data/datasources/local/app_database.dart' as db;

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedAccountId;
  bool _isInvestment = false;
  int _emotionalScore = 0;

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountListControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.baseColor,
      appBar: AppBar(
        title: const Text('取引を追加', style: TextStyle(color: AppTheme.textColor)),
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
              // Amount
              NeumorphicContainer(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '金額',
                    border: InputBorder.none,
                    prefixText: '¥ ',
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
                data: (accounts) {
                  final accountList = accounts.cast<db.Account>();

                  if (accountList.isEmpty) {
                    return const Text('口座が見つかりません。先に口座を作成してください。');
                  }

                  return NeumorphicContainer(
                    child: DropdownButtonFormField<int>(
                      value: _selectedAccountId,
                      decoration: const InputDecoration(
                        labelText: '口座',
                        border: InputBorder.none,
                      ),
                      items: accountList.map((account) {
                        return DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAccountId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? '口座を選択してください' : null,
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading accounts: $err'),
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
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      '保存する',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
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

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('口座を選択してください')),
        );
        return;
      }

      final amount = double.tryParse(_amountController.text) ?? 0;

      await ref
          .read(transactionListControllerProvider.notifier)
          .addTransaction(
            accountId: _selectedAccountId!,
            amount: amount,
            date: _selectedDate,
            isInvestment: _isInvestment,
            emotionalScore: _emotionalScore,
            note: _noteController.text,
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
