import 'package:flutter/material.dart';
import './utils.dart';
import './my_expenses_db.dart';

class AddExpensePage extends StatefulWidget {
    @override
    _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> with SingleTickerProviderStateMixin {
    final Text _title = Text('Add expense');
    final GlobalKey<FormState> _formKey = GlobalKey();
    ExpenseModel _expense = ExpenseModel();
    ExpenseMeaning _expenseMeaning = ExpenseMeaning.EXITS;

    @override
    void initState() {
        super.initState();
    }

    @override
    void dispose() {
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: _title,
                actions: [
                    IconButton(
                        icon: Icon(Icons.check),
                        onPressed: _save,
                    )
                ],
            ),
            body: Form(
                key: _formKey,
                child: ListView(
                    children: [
                        ListTile(
                            leading: IconButton(
                                icon: () {
                                    if (_expenseMeaning == ExpenseMeaning.ENTERED) {
                                        return Icon(
                                            Icons.arrow_upward,
                                            color: Colors.green
                                        );
                                    }

                                    return Icon(
                                        Icons.arrow_downward,
                                        color: Colors.red
                                    );
                                }(),
                                onPressed: () {
                                    setState(() {
                                        if (_expenseMeaning == ExpenseMeaning.ENTERED) {
                                            _expenseMeaning = ExpenseMeaning.EXITS;
                                            return;
                                        }

                                        _expenseMeaning = ExpenseMeaning.ENTERED;
                                    });
                                },
                            ),
                            title: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: 'Amout'
                                ),
                                onSaved: (String value) {
                                    try {
                                        _expense.amount = double.tryParse(value);
                                    } catch (e) {
                                        print(e);
                                    }
                                },
                            ),
                        ),
                        ListTile(
                            title: TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Description',
                                ),
                                onSaved: (String value) {
                                    _expense.description = value;
                                },
                                keyboardType: TextInputType.multiline,
                                maxLines: 2,
                            ),
                        ),
                    ],
                ),
            )
        );
    }

    void _save() {
        _formKey.currentState.save();
        _expense.amount *= _expenseMeaning == ExpenseMeaning.ENTERED ? 1 : -1;

        addExpense(_expense)
        .then((int id) {
            Navigator.pop(context, id);
        })
        .catchError((e) {
            print(e);
        });
    }
}
