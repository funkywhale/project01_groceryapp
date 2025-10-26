import 'package:flutter/material.dart';
import 'models/grocery_list_model.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GroceryListModel model = GroceryListModel();

  @override
  void initState() {
    super.initState();
    model.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Grocery List',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomeScreen(model: model),
    );
  }
}
