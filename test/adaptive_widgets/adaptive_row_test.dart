import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:adaptive_ui/src/base/adaptive_parent_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

    //   testWidgets('are removed from semantics', (tester) async {
    //     await tester.pumpWidget(
    //       MaterialApp(
    //         home: SizedBox(
    //           width: 50,
    //           child: AdaptiveRow(
    //             children: const [
    //               AdaptiveChild(order: 0, child: SizedBox(width: 30, child: Text('A'))),
    //               AdaptiveChild(order: 1, child: SizedBox(width: 30, child: Text('B'))),
    //               AdaptiveChild(order: 2, child: SizedBox(width: 30, child: Text('C'))),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );

    //     final handle = tester.ensureSemantics();

    //     final aSemantics = tester.getSemantics(find.text('A'));
    //     expect(aSemantics.label, 'A');

    //     expect(
    //       () => tester.getSemantics(find.text('B')),
    //       throwsFlutterError,
    //     );

    //     expect(
    //       () => tester.getSemantics(find.text('C')),
    //       throwsFlutterError,
    //     );

    //     handle.dispose();
    //   });
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
}
