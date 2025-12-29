// Copyright (c) 2025 Lucas Nantes da Costa
//
// This file was created by Lucas Nantes da Costa.
// All rights reserved.
//
// SPDX-License-Identifier: MIT

// MARK: RenderBox
import 'package:flutter/rendering.dart';

import '../base/adaptive_parent_data.dart';

class RenderAdaptiveRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AdaptiveParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AdaptiveParentData> {
  RenderAdaptiveRow({double spacing = 0}) : _spacing = spacing;

  double _spacing;
  double get spacing => _spacing;
  set spacing(double value) {
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

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.smallest;
      return;
    }

    // MARK: Lay Pre-Work
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData as AdaptiveParentData;
      assert(parentData.order >= 0, 'AdaptiveRow: order must be a non-negative integer');

      child.layout(constraints.loosen(), parentUsesSize: true);
      parentData.isVisible = false;

      child = parentData.nextSibling;
    }

    // MARK: Group by order
    final groups = <int, List<RenderBox>>{};

    child = firstChild;
    while (child != null) {
      final parentData = child.parentData as AdaptiveParentData;
      groups.putIfAbsent(parentData.order, () => []).add(child);
      child = parentData.nextSibling;
    }

    final sortedOrders = groups.keys.toList()..sort();

    // MARK: Select Visible
    final visibleChildren = <RenderBox>[];
    double usedWidth = 0;
    var hasAnyGroup = false;

    for (final order in sortedOrders) {
      final group = groups[order]!;

      double groupWidth = 0;
      for (final c in group) {
        groupWidth += c.size.width;
      }
      groupWidth += spacing * (group.length - 1);

      final nextWidth = hasAnyGroup ? usedWidth + spacing + groupWidth : groupWidth;

      if (nextWidth > constraints.maxWidth && hasAnyGroup) {
        break;
      }

      visibleChildren.addAll(group);
      usedWidth = nextWidth;
      hasAnyGroup = true;
    }

    // MARK: Position Visible
    double dx = 0;
    double maxHeight = 0;

    for (final c in visibleChildren) {
      final parentData = c.parentData as AdaptiveParentData;
      parentData.isVisible = true;
      parentData.offset = Offset(dx, 0);

      dx += c.size.width + spacing;
      maxHeight = maxHeight < c.size.height ? c.size.height : maxHeight;
    }

    size = constraints.constrain(Size(dx > 0 ? dx - spacing : 0, maxHeight));
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
