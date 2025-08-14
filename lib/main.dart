import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todos/screens/todos_screen.dart';
import 'models/hue_provider.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) => HueProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todos',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan)),
      home: const TodosScreen(title: 'Todos'),
    );
  }
}
