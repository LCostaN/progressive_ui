// Copyright (c) 2025 Lucas Nantes da Costa
//
// This file was created by Lucas Nantes da Costa.
// All rights reserved.
//
// SPDX-License-Identifier: MIT

import 'package:flutter/widgets.dart';

class AdaptiveChild {
  final Widget child;
  final int order;

  const AdaptiveChild({this.order = 0, required this.child}) : assert(order >= 0, 'order cannot be a negative value');
}
