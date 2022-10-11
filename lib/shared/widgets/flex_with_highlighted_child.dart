import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FlexWithHighlightedChild extends Flex {
  final TickerProvider vsync;
  final int active;
  final Color? color;
  final Duration duration;
  final Curve curve;

  FlexWithHighlightedChild({
    required this.vsync,
    required super.direction,
    this.active = -1,
    this.color,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubicEmphasized,
    super.children,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.mainAxisSize,
    super.clipBehavior,
    super.verticalDirection,
    super.textBaseline,
    super.textDirection,
    super.key,
  });

  @override
  RenderFlexWithHighlightedChild createRenderObject(BuildContext context) {
    return RenderFlexWithHighlightedChild(
      direction: direction,
      vsync: vsync,
      active: active,
      color: color ?? Theme.of(context).colorScheme.primaryContainer,
      duration: duration,
      curve: curve,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderFlexWithHighlightedChild renderObject) {
    renderObject
      ..direction = direction
      ..vsync = vsync
      ..active = active
      ..color = color ?? Theme.of(context).colorScheme.primaryContainer
      ..duration = duration
      ..curve = curve
      ..mainAxisAlignment = mainAxisAlignment
      ..mainAxisSize = mainAxisSize
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = getEffectiveTextDirection(context)
      ..verticalDirection = verticalDirection
      ..textBaseline = textBaseline
      ..clipBehavior = clipBehavior;
  }
}


class RenderFlexWithHighlightedChild extends RenderFlex {
  int _active;

  Color _color;

  final AnimationController _controller;

  late final CurvedAnimation _animation;

  final _tween = RectTween();

  TickerProvider _ticker;

  set active(int value) {
    if (_active != value) {
      _active = value;
      markNeedsPaint();
    }
  }

  set color(Color value) {
    if (_color != value) {
      _color = value;
      markNeedsPaint();
    }
  }

  set vsync(TickerProvider value) {
    // required to prevent ticker creation exception for SingleTickerProvider
    if (_ticker != value) {
      _ticker = value;
      _controller.resync(value);
    }
  }

  set duration(Duration value) {
    _controller.duration = value;
  }

  set curve(Curve value) {
    _animation.curve = value;
  }

  RenderFlexWithHighlightedChild({
    required TickerProvider vsync,
    required int active,
    required Color color,
    required Duration duration,
    required Curve curve,
    super.children,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.mainAxisSize,
    super.direction,
    super.clipBehavior,
    super.textBaseline,
    super.textDirection,
    super.verticalDirection,
  }) :
    _active = active,
    _color = color,
    _ticker = vsync,
    _controller = AnimationController(
      vsync: vsync,
      duration: duration,
    )
  {
    _animation = CurvedAnimation(
      parent: _controller,
      curve: curve,
    )..addListener(_handleAnimation);
  }

  void _handleAnimation() {
    if (owner != null && !owner!.debugDoingPaint) {
      markNeedsPaint();
    }
  }

  void _updateTween(RectTween tween, Rect targetValue) {
    tween
      ..begin = _tween.evaluate(_animation) ?? targetValue
      ..end = targetValue;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_active >= 0 && _active < childCount) {
      final activeChild = getChildrenAsList()[_active];
      final childParentData = activeChild.parentData as FlexParentData;
      final childPosition = childParentData.offset + offset;

      final newRect = childPosition & activeChild.size;
      if (_tween.end != newRect) {
        _updateTween(_tween, newRect);
        _controller.forward(from: 0);
      }

      final rect = _tween.evaluate(_animation)!;
      final style = Paint()
        ..color = _color
        ..style = PaintingStyle.fill;
      context.canvas.drawRect(rect, style);
    }
    // draw all flex children
    super.paint(context, offset);
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }
}
