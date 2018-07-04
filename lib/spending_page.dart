import 'package:flutter/material.dart';
import './my_spend_db.dart';
import './types.dart';

class SpendingPage extends StatefulWidget {
    @override
    _SpendingPageState createState() => new _SpendingPageState();
}

class _SpendingPageState extends State<SpendingPage> with SingleTickerProviderStateMixin {
    final Text _title = new Text('Spending');
    List<SpentModel> _spending = [];

    @override
    void initState() {
        super.initState();
        _getSpents();
    }

    @override
    void dispose() {
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                title: _title,
                actions: [
                    IconButton(
                        icon: new Icon(Icons.add),
                        onPressed: () {
                            Navigator.pushNamed(context, '/adding_expenses')
                            .then((id) {
                                if (id == null) {
                                    return;
                                }

                                getSpentById(id)
                                .then((SpentModel s) {
                                    setState(() {
                                        _spending.insert(0, s);
                                    });
                                })
                                .catchError((e) {
                                    print(e);
                                });
                            });
                        },
                    )
                ],
            ),
            body: ListView(
                children: ListTile.divideTiles(
                    context: context,
                    tiles: _spendingTiles()
                )
                .toList()
            )
        );
    }

    Iterable<ListTile> _spendingTiles() {
        return _spending.map((SpentModel s) => ListTile(
            leading: () {
                if (s.amount.isNegative) {
                    return Icon(
                        Icons.arrow_downward,
                        color: Colors.red
                    );
                }

                return Icon(
                    Icons.arrow_upward,
                    color: Colors.green
                );
            }(),
            title: Text(s.amount.abs().toString()),
            subtitle: Text(s.description),
            trailing: Text('${s.date.hour.toString()}:${s.date.minute.toString()}'),
            onTap: () {},
        ));
    }

    void _getSpents() {
        getSpents()
        .then((List<SpentModel> spending) {
            print(spending);
            setState(() {
                _spending = spending;
            });
        })
        .catchError((e) {
            print(e);
        });
    }
}
