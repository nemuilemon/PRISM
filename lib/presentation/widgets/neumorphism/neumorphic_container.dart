import 'package:flutter/material.dart';
import 'package:prism/core/theme/app_theme.dart';

class NeumorphicContainer extends StatelessWidget {
  const NeumorphicContainer({
    required this.child,
    super.key,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.isPressed = false,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        // 簡易的な実装: 押されたときは影をなくして少し暗くする、あるいは逆の影をつける
        // ここでは「押されたらフラットになる」表現を採用
        boxShadow: isPressed
            ? []
            : const [
                BoxShadow(
                  color: AppTheme.darkShadow,
                  offset: Offset(4, 4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: AppTheme.lightShadow,
                  offset: Offset(-4, -4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
        // 押された時の視覚的フィードバックとして背景色を微調整
        gradient: isPressed
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkShadow.withValues(alpha: 0.1),
                  AppTheme.lightShadow.withValues(alpha: 0.1),
                ],
              )
            : null,
      ),
      child: child,
    );
  }
}

// BoxShadowにinsetプロパティはないため、簡易的な実装として修正
// 実際にはパッケージを使わずにInset Shadowを実装するのは複雑なため、
// ここでは「押されたら影が内側っぽく見える（実際は色が暗くなる）」アプローチをとる。
