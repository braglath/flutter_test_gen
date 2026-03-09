import 'package:flutter/material.dart';
import 'package:flutter_test_gen_example/counter_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: CounterPage(),
      );
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final CounterViewModel viewModel = CounterViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_update);
  }

  void _update() => setState(() {});

  @override
  void dispose() {
    viewModel.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Counter App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Counter Value',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                '${viewModel.counter}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: viewModel.decrement,
                    child: const Text('-'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: viewModel.reset,
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: viewModel.increment,
                    child: const Text('+'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
