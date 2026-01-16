// Copyright (c) 2025 Lucas Nantes da Costa
//
// This file was created by Lucas Nantes da Costa.
// All rights reserved.
//
// SPDX-License-Identifier: MIT

import 'package:flutter/rendering.dart';

import '../base/adaptive_parent_data.dart';

class RenderAdaptiveRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AdaptiveParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AdaptiveParentData> {
  // MARK: RenderAdaptiveRow
  RenderAdaptiveRow({
    required MainAxisAlignment mainAxisAlignment,
    required MainAxisSize mainAxisSize,
    required CrossAxisAlignment crossAxisAlignment,
    required TextDirection textDirection,
    required VerticalDirection verticalDirection,
    TextBaseline? textBaseline,
    double spacing = 0,
  })  : assert(spacing >= 0, 'RenderAdaptiveRow.spacing must be >= 0'),
        assert(
          crossAxisAlignment != CrossAxisAlignment.baseline || textBaseline != null,
          'RenderAdaptiveRow: textBaseline is required when using CrossAxisAlignment.baseline',
        ),
        _mainAxisAlignment = mainAxisAlignment,
        _mainAxisSize = mainAxisSize,
        _crossAxisAlignment = crossAxisAlignment,
        _textDirection = textDirection,
        _verticalDirection = verticalDirection,
        _textBaseline = textBaseline,
        _spacing = spacing;

  // MARK: Parameters
  MainAxisAlignment _mainAxisAlignment;
  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment == value) return;
    _mainAxisAlignment = value;
    markNeedsLayout();
  }

  MainAxisSize _mainAxisSize;
  MainAxisSize get mainAxisSize => _mainAxisSize;
  set mainAxisSize(MainAxisSize value) {
    if (_mainAxisSize == value) return;
    _mainAxisSize = value;
    markNeedsLayout();
  }

  CrossAxisAlignment _crossAxisAlignment;
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  VerticalDirection _verticalDirection;
  VerticalDirection get verticalDirection => _verticalDirection;
  set verticalDirection(VerticalDirection value) {
    if (_verticalDirection == value) return;
    _verticalDirection = value;
    markNeedsLayout();
  }

  TextBaseline? _textBaseline;
  TextBaseline? get textBaseline => _textBaseline;
  set textBaseline(TextBaseline? value) {
    if (_textBaseline == value) return;
    _textBaseline = value;
    markNeedsLayout();
  }

  double _spacing;
  double get spacing => _spacing;
  set spacing(double value) {
    assert(value >= 0, 'RenderAdaptiveRow.spacing must be >= 0');
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! AdaptiveParentData) {
      child.parentData = AdaptiveParentData();
    }
  }

  // MARK: Layout
  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.smallest;
      return;
    }

    final isStretch = crossAxisAlignment == CrossAxisAlignment.stretch;
    final isRtl = textDirection == TextDirection.rtl;

    final hasBoundedHeight = constraints.hasBoundedHeight;
    final maxHeight = hasBoundedHeight ? constraints.maxHeight : double.infinity;

    // Pre-layout
    var child = firstChild;
    while (child != null) {
      final pd = child.parentData as AdaptiveParentData;

      child.layout(
        isStretch && hasBoundedHeight
            ? BoxConstraints(
                minWidth: 0,
                maxWidth: constraints.maxWidth,
                minHeight: maxHeight,
                maxHeight: maxHeight,
              )
            : constraints.loosen(),
        parentUsesSize: true,
      );

      pd.isVisible = false;
      child = pd.nextSibling;
    }

    // Group by order
    final groups = <int, List<RenderBox>>{};
    child = firstChild;
    while (child != null) {
      final pd = child.parentData as AdaptiveParentData;
      groups.putIfAbsent(pd.order, () => []).add(child);
      child = pd.nextSibling;
    }

    final orders = groups.keys.toList()..sort();

    // Select visible
    final visible = <RenderBox>[];
    double usedWidth = 0;
    var hasAny = false;

    for (final order in orders) {
      final group = groups[order]!;
      var w = group.fold(0.0, (v, c) => v + c.size.width);
      w += spacing * (group.length - 1);

      final next = hasAny ? usedWidth + spacing + w : w;
      if (next > constraints.maxWidth && hasAny) break;

      visible.addAll(group);
      usedWidth = next;
      hasAny = true;
    }

    // MainAxisSize
    final containerWidth = mainAxisSize == MainAxisSize.max ? constraints.maxWidth : usedWidth;
    final remaining = (containerWidth - usedWidth).clamp(0.0, double.infinity);

    // MainAxisAlignment
    double leadingSpace = 0;
    var betweenSpace = spacing;

    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        if (isRtl) leadingSpace = remaining;
        break;
      case MainAxisAlignment.end:
        if (!isRtl) leadingSpace = remaining;
        break;
      case MainAxisAlignment.center:
        leadingSpace = remaining / 2;
        break;
      case MainAxisAlignment.spaceBetween:
        if (visible.length > 1) {
          betweenSpace = spacing + remaining / (visible.length - 1);
        }
        break;
      case MainAxisAlignment.spaceAround:
        if (visible.isNotEmpty) {
          betweenSpace = spacing + remaining / visible.length;
          leadingSpace = betweenSpace / 2;
        }
        break;
      case MainAxisAlignment.spaceEvenly:
        if (visible.isNotEmpty) {
          betweenSpace = spacing + remaining / (visible.length + 1);
          leadingSpace = betweenSpace;
        }
        break;
    }

    // CrossAxis
    final maxChildHeight = visible.fold<double>(
      0,
      (v, c) => v < c.size.height ? c.size.height : v,
    );

    final containerHeight = hasBoundedHeight ? constraints.maxHeight : maxChildHeight;
    final layoutHeight = isStretch ? containerHeight : maxChildHeight;

    var dx = isRtl ? containerWidth - leadingSpace : leadingSpace;

    for (final c in visible) {
      final pd = c.parentData as AdaptiveParentData;
      pd.isVisible = true;

      double dy = 0;
      switch (crossAxisAlignment) {
        case CrossAxisAlignment.start:
          dy = 0;
          break;
        case CrossAxisAlignment.end:
          dy = layoutHeight - c.size.height;
          break;
        case CrossAxisAlignment.center:
          dy = (layoutHeight - c.size.height) / 2;
          break;
        case CrossAxisAlignment.baseline:
          if (textBaseline != null) {
            final baseline = c.getDistanceToBaseline(textBaseline!) ?? 0;
            dy = layoutHeight - baseline;
          }
          break;
        case CrossAxisAlignment.stretch:
          dy = 0;
          break;
      }

      if (verticalDirection == VerticalDirection.up) {
        dy = layoutHeight - c.size.height - dy;
      }

      if (isRtl) {
        dx -= c.size.width;
        pd.offset = Offset(dx, dy);
        dx -= betweenSpace;
      } else {
        pd.offset = Offset(dx, dy);
        dx += c.size.width + betweenSpace;
      }
    }

    size = constraints.constrain(Size(containerWidth, containerHeight));
  }

  // MARK: Paint
  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData as AdaptiveParentData;

      if (parentData.isVisible) {
        context.paintChild(child, parentData.offset + offset);
      }

      child = parentData.nextSibling;
    }
  }

  // MARK: HitTest
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    while (child != null) {
      final parentData = child.parentData as AdaptiveParentData;

      if (parentData.isVisible &&
          result.addWithPaintOffset(
            offset: parentData.offset,
            position: position,
            hitTest: (result, transformed) => child!.hitTest(result, position: transformed),
          )) {
        return true;
      }

      child = parentData.previousSibling;
    }
    return false;
  }

// MARK: Semantics
  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData as AdaptiveParentData;
      if (parentData.isVisible) {
        visitor(child);
      }
      child = parentData.nextSibling;
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.explicitChildNodes = true;
    config.isSemanticBoundary = false;
  }

  @override
  void assembleSemanticsNode(
    SemanticsNode node,
    SemanticsConfiguration config,
    Iterable<SemanticsNode> children,
  ) {
    final visibleChildren = <SemanticsNode>[];
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData as AdaptiveParentData;

      if (parentData.isVisible) {
        final semantics = child.debugSemantics;
        if (semantics != null) {
          visibleChildren.add(semantics);
        }
      }

      child = parentData.nextSibling;
    }

    node.updateWith(
      config: config,
      childrenInInversePaintOrder: visibleChildren,
    );
  }
}
