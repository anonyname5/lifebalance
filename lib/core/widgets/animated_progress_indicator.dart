import 'package:flutter/material.dart';

/// Animated progress indicator that animates from 0 to target value
class AnimatedProgressIndicator extends StatefulWidget {
  final double value;
  final double minHeight;
  final Color? backgroundColor;
  final Color? valueColor;
  final Duration duration;
  final Curve curve;

  const AnimatedProgressIndicator({
    super.key,
    required this.value,
    this.minHeight = 4.0,
    this.backgroundColor,
    this.valueColor,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedValue = widget.value * _animation.value;
        return LinearProgressIndicator(
          value: animatedValue > 1.0 ? 1.0 : animatedValue,
          minHeight: widget.minHeight,
          backgroundColor: widget.backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.valueColor ?? Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }
}

/// Animated circular progress indicator
class AnimatedCircularProgressIndicator extends StatefulWidget {
  final double value;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;
  final Duration duration;
  final Curve curve;

  const AnimatedCircularProgressIndicator({
    super.key,
    required this.value,
    this.strokeWidth = 4.0,
    this.backgroundColor,
    this.valueColor,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedCircularProgressIndicator> createState() => _AnimatedCircularProgressIndicatorState();
}

class _AnimatedCircularProgressIndicatorState extends State<AnimatedCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedValue = widget.value * _animation.value;
        return CircularProgressIndicator(
          value: animatedValue > 1.0 ? 1.0 : animatedValue,
          strokeWidth: widget.strokeWidth,
          backgroundColor: widget.backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.valueColor ?? Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }
}
