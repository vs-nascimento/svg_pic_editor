import 'package:flutter/material.dart';

import '../ui/svg_pic_editor.dart';

extension AnimatedSvgPicEditor on SvgPicEditor {
  /// Anima o widget com o efeito de shake.
  Widget shake({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 500),
    double offset = 10.0,
    bool isInfinite = false,
    Curve curve = Curves.easeInOut,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    final animation = Tween<double>(begin: -offset, end: offset).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );

    // Inicia a animação
    if (isInfinite) {
      controller.repeat(reverse: true);
    } else {
      controller.forward().then((_) => controller.dispose());
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(animation.value, 0),
          child: child,
        );
      },
      child: this,
    );
  }

  /// Anima o widget com o efeito de rotação.
  Widget rotate({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 500),
    double angle = 1.0,
    bool isInfinite = false,
    Curve curve = Curves.linear,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    final animation = Tween<double>(begin: 0.0, end: angle).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );

    // Inicia a animação
    if (isInfinite) {
      controller.repeat();
    } else {
      controller.forward().then((_) => controller.dispose());
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value,
          child: child,
        );
      },
      child: this,
    );
  }

  /// Anima o widget com o efeito de vibração.
  Widget vibrate({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 500),
    double amplitude = 5.0,
    bool isInfinite = false,
    Curve curve = Curves.linear,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    final animation = Tween<double>(begin: -amplitude, end: amplitude).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );

    // Inicia a animação
    if (isInfinite) {
      controller.repeat(reverse: true);
    } else {
      controller.forward().then((_) => controller.dispose());
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(animation.value, 0),
          child: child,
        );
      },
      child: this,
    );
  }

  /// Anima o widget com uma animação personalizada.
  Widget customAnimation({
    required TickerProvider vsync,
    required Animation<double> animation,
    Duration duration = const Duration(milliseconds: 500),
    bool isInfinite = false,
    Curve curve = Curves.linear,
    required Widget Function(BuildContext context, double value) builder,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    final animatedValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );

    // Inicia a animação
    if (isInfinite) {
      controller.repeat();
    } else {
      controller.forward().then((_) => controller.dispose());
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return builder(context, animatedValue.value);
      },
      child: this,
    );
  }
}
