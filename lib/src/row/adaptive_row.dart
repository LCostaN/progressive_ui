// Copyright (c) 2025 Lucas Nantes da Costa
//
// This file was created by Lucas Nantes da Costa.
// All rights reserved.
//
// SPDX-License-Identifier: MIT

import 'package:flutter/widgets.dart';

import '../base/adaptive_child.dart';
import '../base/adaptive_parent_data.dart';
import 'render_adaptive_row.dart';

// MARK: Slot
class _AdaptiveSlot extends ParentDataWidget<AdaptiveParentData> {
  final int order;

  const _AdaptiveSlot({
    required this.order,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as AdaptiveParentData;

    if (parentData.order != order) {
      parentData.order = order;
      final parent = renderObject.parent;
      if (parent is RenderObject) {
        parent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => AdaptiveRow;
}

/// A horizontal layout widget that conditionally renders groups of children
/// based on the available horizontal space.
///
/// Children are assigned an integer `order` (via [AdaptiveChild]) and are
/// **grouped by that order**. Groups are laid out from lowest order to highest,
/// and **only whole groups are rendered**.
///
/// Layout rules:
/// - Groups are evaluated in ascending `order`.
/// - A group is rendered only if **all widgets in that group fit**.
/// - If a group does not fit, it and all subsequent groups are skipped.
/// - If all children have `order = 0`, this behaves like a regular [Row].
/// - Spacing is applied between widgets and between groups.
///
/// This makes it possible to express Adaptive behavior such as:
/// - Required vs optional content
/// - Progressive disclosure of UI elements
/// - Adaptive toolbars or filter rows
///
/// Example:
/// ```dart
/// AdaptiveRow(
///   spacing: 8,
///   children: const [
///     AdaptiveChild(
///       order: 0,
///       child: Text('Required'),
///     ),
///     AdaptiveChild(
///       order: 1,
///       child: Icon(Icons.download),
///     ),
///     AdaptiveChild(
///       order: 2,
///       child: Text('Optional'),
///     ),
///   ],
/// )
/// ```
///
/// In the example above:
/// - All widgets render if space allows
/// - Only `order = 0` renders on smaller widths
/// - `order = 1` and `order = 2` are progressively hidden as space decreases
///
/// Note:
/// - `order` must be a non-negative integer.
/// - Overflow behavior is not handled internally; if even the lowest-order
///   group does not fit, standard Flutter overflow behavior applies.
// MARK: AdaptiveRow
class AdaptiveRow extends MultiChildRenderObjectWidget {
  final double spacing;

  AdaptiveRow({super.key, this.spacing = 0, required List<AdaptiveChild> children})
      : super(
          children: children.map((c) => _AdaptiveSlot(order: c.order, child: c.child)).toList(),
        );

  @override
  RenderObject createRenderObject(BuildContext context) => RenderAdaptiveRow(spacing: spacing);

  @override
  void updateRenderObject(BuildContext context, RenderAdaptiveRow renderObject) => renderObject.spacing = spacing;
}
