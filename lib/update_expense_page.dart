import 'package:flutter/material.dart';
import './utils.dart';
import './my_expenses_db.dart';

class UpdateExpensePage extends StatefulWidget {
    final ExpenseModel expense;

    UpdateExpensePage(this.expense);

    @override
    _UpdateExpensePageState createState() => _UpdateExpensePageState();
}

class _UpdateExpensePageState extends State<UpdateExpensePage> with SingleTickerProviderStateMixin {
    final Text _title = Text('Update expense');
    final GlobalKey<FormState> _formKey = GlobalKey();
    ExpenseModel _expense;
    ExpenseMeaning _expenseMeaning = ExpenseMeaning.EXITS;

    @override
    void initState() {
        super.initState();
        _expense = widget.expense;

        if (!_expense.amount.isNegative) {
            _expenseMeaning = ExpenseMeaning.ENTERED;
        }
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
            body: _buidForm()
        );
    }

    void _save() {
        _formKey.currentState.save();

        updateExpense(_expense)
        .then((_) {
            Navigator.pop(context, {
                'code': 'updated',
                'data': _expense
            });
        })
        .catchError((e) {
            print(e);
        });
    }

    Form _buidForm() {
        Icon leadingIcon = Icon(
            Icons.arrow_downward,
            color: Colors.red
        );

        if (_expenseMeaning == ExpenseMeaning.ENTERED) {
            leadingIcon = Icon(
                Icons.arrow_upward,
                color: Colors.green
            );
        }

        void leadingOnPressed() {
            setState(() {
                if (_expenseMeaning == ExpenseMeaning.ENTERED) {
                    _expenseMeaning = ExpenseMeaning.EXITS;
                    return;
                }

                _expenseMeaning = ExpenseMeaning.ENTERED;
            });
        }

        List<Widget> children = [];

        if (DateTime.now().difference(_expense.date).inHours < 1) {
            children.add(ListTile(
                leading: IconButton(
                    icon: leadingIcon,
                    onPressed: leadingOnPressed,
                ),
                title: TextFormField(
                    initialValue: _expense.amount.abs().toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Amout'
                    ),
                    onSaved: (String value) {
                        _expense.amount = double.parse(value) * (_expenseMeaning == ExpenseMeaning.ENTERED ? 1 : -1);
                    },
                ),
            ));
        }

        children.add(ListTile(
            title: TextFormField(
                initialValue: _expense.description,
                decoration: InputDecoration(
                    labelText: 'Description',
                ),
                onSaved: (String value) {
                    _expense.description = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: 2,
            ),
        ));
        children.add(CheckboxListTile(
            title: Text('Hide'),
            value: _expense.hide,
            onChanged: (bool value) {
                setState(() {
                    _expense.hide = value;
                });
            },
        ));

        return Form(
            key: _formKey,
            child: ListView(children: children)
        );
    }
}
