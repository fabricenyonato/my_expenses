import 'package:flutter/material.dart';
import './types.dart';
import './my_spend_db.dart';

class AddingExpensesPage extends StatefulWidget {
    @override
    _AddingExpensesPageState createState() => _AddingExpensesPageState();
}

class _AddingExpensesPageState extends State<AddingExpensesPage> with SingleTickerProviderStateMixin {
    final Text _title = Text('Adding expenses');
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    SpentModel _spent = SpentModel();
    SpentMeaning _spentMeaning = SpentMeaning.exits;

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
                                    if (_spentMeaning == SpentMeaning.entered) {
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
                                        if (_spentMeaning == SpentMeaning.entered) {
                                            _spentMeaning = SpentMeaning.exits;
                                            return;
                                        }

                                        _spentMeaning = SpentMeaning.entered;
                                    });
                                },
                            ),
                            title: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: 'Amout'
                                ),
                                onSaved: (String value) {
                                    try {
                                        _spent.amount = double.tryParse(value);
                                    } catch (e) {
                                        print(e);
                                    }
                                },
                            ),
                        ),
                        ListTile(
                            title: TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Description',
                                ),
                                onSaved: (String value) {
                                    _spent.description = value;
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
        _spent.amount *= _spentMeaning == SpentMeaning.entered ? 1 : -1;

        addSpent(_spent)
        .then((int id) {
            Navigator.pop(context, id);
        })
        .catchError((e) {
            print(e);
        });
    }
}
