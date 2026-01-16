// Copyright (c) 2025 Lucas Nantes da Costa
//
// This file was created by Lucas Nantes da Costa.
// All rights reserved.
//
// SPDX-License-Identifier: MIT

import 'package:flutter/widgets.dart';

class AdaptiveChild extends StatelessWidget {
  final Widget child;
  final int order;

  const AdaptiveChild({
    super.key,
    this.order = 0,
    required this.child,
  }) : assert(order >= 0, 'order cannot be a negative value');

  @override
  Widget build(BuildContext context) => child;
}
