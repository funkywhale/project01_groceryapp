import 'package:flutter/material.dart';
import 'models/grocery_list_model.dart';
import 'screens/main_tabs.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GroceryListModel model = GroceryListModel();

  @override
  void initState() {
    super.initState();
    model.addListener(() => setState(() {}));
    model.loadFromPrefs();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green),
      home: MainTabs(model: model),
    );
  }
}
