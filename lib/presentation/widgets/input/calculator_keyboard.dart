import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:prism/core/theme/app_theme.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_button.dart';

class CalculatorKeyboard extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const CalculatorKeyboard({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  State<CalculatorKeyboard> createState() => _CalculatorKeyboardState();
}

class _CalculatorKeyboardState extends State<CalculatorKeyboard> {
  late String _expression;

  @override
  void initState() {
    super.initState();
    _expression = widget.initialValue == '0' ? '' : widget.initialValue;
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == 'C') {
        _expression = '';
      } else if (key == 'DEL') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (key == '=') {
        _evaluate();
      } else {
        _expression += key;
      }
    });
    widget.onChanged(_expression);
  }

  void _evaluate() {
    try {
      final p = GrammarParser();
      final exp = p.parse(
        _expression.replaceAll('x', '*').replaceAll('÷', '/'),
      );
      final cm = ContextModel();
      final eval = exp.evaluate(EvaluationType.REAL, cm) as double;

      // 整数なら.0を消す
      String result = eval.toString();
      if (result.endsWith('.0')) {
        result = result.substring(0, result.length - 2);
      }

      setState(() {
        _expression = result;
      });
      widget.onChanged(_expression);
    } catch (e) {
      // エラー時は何もしないか、エラー表示
      debugPrint('Calc Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.baseColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display Area (Optional, if we want to show current expression here)
          // For now, we rely on the parent input field updating via onChanged
          Row(
            children: [
              _buildButton('7'),
              _buildButton('8'),
              _buildButton('9'),
              _buildButton('÷', color: Colors.orange),
            ],
          ),
          Row(
            children: [
              _buildButton('4'),
              _buildButton('5'),
              _buildButton('6'),
              _buildButton('x', color: Colors.orange),
            ],
          ),
          Row(
            children: [
              _buildButton('1'),
              _buildButton('2'),
              _buildButton('3'),
              _buildButton('-', color: Colors.orange),
            ],
          ),
          Row(
            children: [
              _buildButton('0'),
              _buildButton('.'),
              _buildButton(
                '=',
                color: Colors.green,
                onPressed: () {
                  _evaluate();
                  // 計算結果を確定として送信するならここだが、
                  // ユーザーは計算後にOKボタンを押したいかもしれない。
                  // ここでは計算実行のみにする。
                },
              ),
              _buildButton('+', color: Colors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildButton('C', color: Colors.red),
              _buildButton('DEL', color: Colors.red),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: NeumorphicButton(
                    onPressed: widget.onSubmit,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, {Color? color, VoidCallback? onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: NeumorphicButton(
          onPressed: onPressed ?? () => _onKeyPressed(text),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8), // 12 -> 8 に縮小
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color ?? AppTheme.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
