import 'package:flutter/material.dart';
import 'package:prism/presentation/widgets/neumorphism/neumorphic_container.dart';

class NeumorphicButton extends StatefulWidget {
  const NeumorphicButton({
    required this.child,
    required this.onPressed,
    super.key,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isPressed = false;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: NeumorphicContainer(
        borderRadius: widget.borderRadius,
        padding: widget.padding,
        isPressed: _isPressed,
        child: Center(child: widget.child),
      ),
    );
  }
}
