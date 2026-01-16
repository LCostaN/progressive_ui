import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progressive_ui/progressive_ui.dart';
import 'package:progressive_ui/src/base/adaptive_parent_data.dart';

AdaptiveParentData _parentData(WidgetTester tester, String key) {
  final renderBox = tester.renderObject<RenderBox>(find.byKey(Key(key)));
  return renderBox.parentData! as AdaptiveParentData;
}

void expectVisible(WidgetTester tester, String key) {
  expect(_parentData(tester, key).isVisible, isTrue);
}

void expectHidden(WidgetTester tester, String key) {
  expect(_parentData(tester, key).isVisible, isFalse);
}

Widget _buildTestRow(double width) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: AdaptiveRow(
            spacing: 8,
            children: const [
              AdaptiveChild(
                order: 0,
                child: SizedBox(key: Key('child-0'), width: 40, height: 20),
              ),
              AdaptiveChild(
                order: 1,
                child: SizedBox(key: Key('child-1'), width: 80, height: 20),
              ),
              AdaptiveChild(
                order: 2,
                child: SizedBox(key: Key('child-2'), width: 40, height: 20),
              ),
            ],
          ),
        ),
      ),
    );

void main() {
  group('Hidden Adaptive Children', () {
    testWidgets('are not hit-testable', (tester) async {
      await tester.pumpWidget(_buildTestRow(120));
      expect(find.byKey(const Key('child-2')).hitTestable(), findsNothing);
    });

    testWidgets('are not painted', (tester) async {
      await tester.pumpWidget(_buildTestRow(120));
      final renderBox = tester.renderObject<RenderBox>(
        find.byKey(const Key('child-2')),
      );
      expect(renderBox, paintsNothing);
    });
  });

  group('Layout', () {
    testWidgets('shows only order 0 when space fits only first group', (tester) async {
      await tester.pumpWidget(_buildTestRow(60));

      expectVisible(tester, 'child-0');
      expectHidden(tester, 'child-1');
      expectHidden(tester, 'child-2');
    });

    testWidgets('shows order 0 and 1 when space fits two groups', (tester) async {
      await tester.pumpWidget(_buildTestRow(140));

      expectVisible(tester, 'child-0');
      expectVisible(tester, 'child-1');
      expectHidden(tester, 'child-2');
    });

    testWidgets('shows order 0, 1 and 2 when space fits all groups', (tester) async {
      await tester.pumpWidget(_buildTestRow(200));

      expectVisible(tester, 'child-0');
      expectVisible(tester, 'child-1');
      expectVisible(tester, 'child-2');
    });

    testWidgets(
      'does not skip order when a higher order would fit but a lower one does not',
      (tester) async {
        await tester.pumpWidget(_buildTestRow(90));

        expectVisible(tester, 'child-0');
        expectHidden(tester, 'child-1');
        expectHidden(tester, 'child-2');
      },
    );
  });

  group('Row Properties', () {
    group('MainAxisAlignment', () {
      testWidgets('center positions children centered', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              width: 200,
              child: AdaptiveRow(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(key: Key('a'), width: 40, height: 20),
                  SizedBox(key: Key('b'), width: 40, height: 20),
                ],
              ),
            ),
          ),
        );

        final a = tester.getRect(find.byKey(const Key('a')));
        final b = tester.getRect(find.byKey(const Key('b')));

        expect(a.left, greaterThan(0));
        expect(b.left - a.right, equals(0));
      });
    });

    group('MainAxisSize', () {
      testWidgets('min wraps content', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: AdaptiveRow(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(width: 30, height: 10),
                  SizedBox(width: 30, height: 10),
                ],
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(AdaptiveRow));
        expect(size.width, 60);
      });
    });

    group('CrossAxisAlignment', () {
      testWidgets('end aligns bottoms', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveRow(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                SizedBox(key: Key('a'), width: 20, height: 10),
                SizedBox(key: Key('b'), width: 20, height: 30),
              ],
            ),
          ),
        );

        final a = tester.getRect(find.byKey(const Key('a')));
        final b = tester.getRect(find.byKey(const Key('b')));

        expect(a.bottom, b.bottom);
      });

      testWidgets('stretch stretches children height', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox(
                height: 100,
                child: AdaptiveRow(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    SizedBox(key: Key('a'), width: 20),
                    SizedBox(key: Key('b'), width: 20),
                  ],
                ),
              ),
            ),
          ),
        );

        final a = tester.getSize(find.byKey(const Key('a')));
        final b = tester.getSize(find.byKey(const Key('b')));

        expect(a.height, 100);
        expect(b.height, 100);
      });
    });

    group('TextDirection', () {
      testWidgets('rtl reverses horizontal order', (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: AdaptiveRow(
              children: const [
                SizedBox(key: Key('a'), width: 20, height: 10),
                SizedBox(key: Key('b'), width: 20, height: 10),
              ],
            ),
          ),
        );

        final a = tester.getRect(find.byKey(const Key('a')));
        final b = tester.getRect(find.byKey(const Key('b')));

        expect(a.left, greaterThan(b.left));
      });
    });

    group('VerticalDirection', () {
      testWidgets('up inverts vertical alignment', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveRow(
              verticalDirection: VerticalDirection.up,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(key: Key('a'), width: 20, height: 10),
                SizedBox(key: Key('b'), width: 20, height: 30),
              ],
            ),
          ),
        );

        final a = tester.getRect(find.byKey(const Key('a')));
        final b = tester.getRect(find.byKey(const Key('b')));

        expect(a.top, greaterThan(b.top));
      });
    });

    group('Spacing', () {
      testWidgets('applies spacing between children', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveRow(
              spacing: 10,
              children: const [
                SizedBox(key: Key('a'), width: 20, height: 10),
                SizedBox(key: Key('b'), width: 20, height: 10),
              ],
            ),
          ),
        );

        final a = tester.getRect(find.byKey(const Key('a')));
        final b = tester.getRect(find.byKey(const Key('b')));

        expect(b.left - a.right, 10);
      });
    });
  });
}
