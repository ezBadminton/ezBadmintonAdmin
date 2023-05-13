import 'package:flutter/material.dart';

class PlayerEditingForm extends StatelessWidget {
  const PlayerEditingForm({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const PlayerEditingForm());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit')),
      body: const Placeholder(),
    );
  }
}
