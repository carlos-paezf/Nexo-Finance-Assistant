import 'package:flutter/material.dart';

void main() => runApp(const WindowsAccessibilityProbe());

class WindowsAccessibilityProbe extends StatelessWidget {
  const WindowsAccessibilityProbe({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Nexo synthetic accessibility probe',
        home: Scaffold(
          appBar: AppBar(title: const Text('UIA probe synthetic')),
          body: ListView(
            children: [
              const Text('Plain Text synthetic sample'),
              const SelectableText('SelectableText synthetic sample'),
              ExpansionTile(
                title: Semantics(
                  button: true,
                  child: Text('ExpansionTile probe synthetic'),
                ),
                children: const [
                  Text('Expanded plain Text synthetic body'),
                  SelectableText('Expanded SelectableText synthetic body'),
                ],
              ),
            ],
          ),
        ),
      );
}
