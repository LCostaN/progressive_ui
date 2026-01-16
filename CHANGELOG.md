## 0.2.0

- Adds full alignment support to `AdaptiveRow`:
  - `MainAxisAlignment`
  - `MainAxisSize`
  - `CrossAxisAlignment`
  - `TextDirection`
  - `VerticalDirection`
- Implements cross-axis layout logic, including `CrossAxisAlignment.stretch`.
- Adds RTL-aware horizontal layout behavior.
- Introduces vertical positioning logic for start, center, end, baseline, and stretch.
- Expands widget tests to cover alignment, stretch, and RTL scenarios.

## 0.1.0

- Initial release.
- Introduces `AdaptiveRow` for progressive UI composition based on available width.
- Supports grouped children using `AdaptiveChild(order: ...)`.
- Ensures children are shown in ascending order without skipping.
- Includes example app and widget tests.
