import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todos/screens/todos_screen.dart';
import 'models/hue_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hueProvider = await HueProvider.load();
  runApp(ChangeNotifierProvider(create: (_) => hueProvider, child: const MyApp()));
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
