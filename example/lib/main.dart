import 'package:flutter/material.dart';
import 'package:progressive_ui/progressive_ui.dart';

void main() {
  runApp(const AdaptiveUiExampleApp());
}

class AdaptiveUiExampleApp extends StatelessWidget {
  const AdaptiveUiExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'progressive_ui example',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
    home: const ExamplePage(),
  );
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AdaptiveRow example')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          const Text('Resize the window to see items appear/disappear.', style: TextStyle(fontSize: 14)),

          const Text('Only groups of items that fit in space will be shown', style: TextStyle(fontSize: 14)),

          const Text('Items are grouped by "order"', style: TextStyle(fontSize: 14)),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AdaptiveRow(
              spacing: 8,
              children: const [
                AdaptiveChild(
                  order: 0,
                  child: _Chip(color: Colors.yellow, label: 'Order 0'),
                ),
                AdaptiveChild(
                  order: 1,
                  child: _Chip(color: Colors.green, label: 'Order 1'),
                ),
                AdaptiveChild(
                  order: 2,
                  child: _Chip(color: Colors.blue, label: 'Order 2'),
                ),
                AdaptiveChild(
                  order: 3,
                  child: _Chip(color: Colors.teal, label: 'Order 3'),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AdaptiveRow(
              spacing: 8,
              children: const [
                AdaptiveChild(
                  order: 0,
                  child: _Chip(color: Colors.yellow, label: 'Order 0'),
                ),
                AdaptiveChild(
                  order: 0,
                  child: _Chip(color: Colors.yellow, label: 'Order 0'),
                ),
                AdaptiveChild(
                  order: 1,
                  child: _Chip(color: Colors.red, label: 'Order 1'),
                ),
                AdaptiveChild(
                  order: 1,
                  child: _Chip(color: Colors.red, label: 'Order 1'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;

  const _Chip({required this.label, this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color ?? Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label),
  );
}
