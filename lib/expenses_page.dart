import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './my_expenses_db.dart';
import './utils.dart';

class ExpensesPage extends StatefulWidget {
    @override
    _ExpensesPageState createState() => new _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> with SingleTickerProviderStateMixin {
    List<ExpenseModel> _expenses = [];
    DateTime _date = DateTime.now();
    DateTime _firstExpenseDate;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

    @override
    void initState() {
        super.initState();
        _getExpenses();
        _getFirstExpenseDate();
    }

    @override
    void dispose() {
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            key: _scaffoldKey,
            appBar: new AppBar(
                title: Text(_isToday() ? 'Today' : DateFormat.yMMMMd().format(_date)),
                actions: [
                    IconButton(
                        icon: Icon(Icons.navigate_before),
                        onPressed: _changeDay(false),
                    ),
                    IconButton(
                        icon: Icon(Icons.navigate_next),
                        onPressed: _changeDay(),
                    ),
                    PopupMenuButton<int>(
                        onSelected: onAppBarDropdownButtonChanged,
                        itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                                value: 0,
                                child: const Text('Solde')
                            ),
                        ],
                    )
                ],
            ),
            body: ListView(
                children: ListTile.divideTiles(
                    context: context,
                    tiles: _spendingTiles()
                )
                .toList()
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: _openAddExpensePage,
                tooltip: 'Add expense',
                child: Icon(Icons.add),
            ), 
        );
    }

    Iterable<ListTile> _spendingTiles() {
        return _expenses.map((ExpenseModel expense) {
            return ListTile(
                leading: () {
                    if (expense.amount.isNegative) {
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
                title: Text(expense.amount.abs().toString()),
                subtitle: Text(expense.description),
                trailing: Text(DateFormat.Hm().format(expense.date)),
                onTap: () {},
            );
        });
    }

    void _getExpenses() {
        getExpenses(date: _date)
        .then((List<ExpenseModel> expenses) {
            print(expenses);
            setState(() {
                _expenses = expenses;
            });
        })
        .catchError((e) {
            print(e);
        });
    }

    void _getFirstExpenseDate() {
        getFirstExpenseDate()
        .then((DateTime d) {
            _firstExpenseDate = d;
        })
        .catchError((e) {
            print(e);
        });
    }

    void _openAddExpensePage() {
        Navigator.pushNamed(context, Routes.ADD_EXPENSE_PAGE)
        .then((id) {
            if (id == null) {
                return;
            }

            getExpenseById(id)
            .then((ExpenseModel s) {
                setState(() {
                    _expenses.insert(0, s);
                });
            })
            .catchError((e) {
                print(e);
            });
        });
    }

    bool _isToday() {
        final DateTime today = DateTime.now();

        return today.day == _date.day && today.month == _date.month && today.year == _date.year;
    }

    bool _isFirstExpenseDate() {
        if (_firstExpenseDate == null) {
            return true;
        }

        return _firstExpenseDate.day == _date.day && _firstExpenseDate.month == _date.month && _firstExpenseDate.year == _date.year;
    }

    VoidCallback _changeDay([bool next = true]) {
        if (_isToday() && next) {
            return null;
        }

        if (_isFirstExpenseDate() && !next) {
            return null;
        }

        return () {
            setState(() {
                _date = _date.add(Duration(days: next ? 1 : -1));
            });

            _getExpenses();
        };
    }

    void onAppBarDropdownButtonChanged(int value) {
        if (value == 0) {
            getSolde()
            .then((double solde) {
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Solde: $solde'),
                ));
            })
            .catchError((e) {
                print(e);
            });

            return;
        }
    }
}
