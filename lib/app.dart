import 'package:flutter/material.dart';
import './spending_page.dart';
import './adding_expenses_page.dart';

class App extends StatelessWidget {
    final ThemeData _theme = new ThemeData(
        primarySwatch: Colors.blue,
    );

    @override
    Widget build(BuildContext context) => new MaterialApp(
        title: 'My spend',
        theme: _theme,
        home: new SpendingPage(),
        routes: _getRoutes(context),
    );

    Map<String, WidgetBuilder> _getRoutes(BuildContext context) => {
        '/spending': (context) => new SpendingPage(),
        '/adding_expenses': (context) => new AddingExpensesPage(),
    };
}
