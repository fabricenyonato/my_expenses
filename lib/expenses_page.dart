import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './my_expenses_db.dart';
import './utils.dart';
import './update_expense_page.dart';

class ExpensesPage extends StatefulWidget {
    @override
    _ExpensesPageState createState() => new _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> with SingleTickerProviderStateMixin {
    List<ExpenseModel> _expenses = [];
    DateTime _date = DateTime.now();
    DateTime _firstExpenseDate;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
    bool _showHiddenExpenses = false;

    @override
    void initState() {
        super.initState();

        SharedPreferences.getInstance()
        .then((SharedPreferences prefs) {
            setState(() {
                _showHiddenExpenses = prefs.getBool(SettingKey.SHOW_HIDDEN_EXPENSES) ?? false;
            });
        })
        .catchError((e) {
            print(e);
        });
    
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
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: _changeDay(false),
                    ),
                    IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: _changeDay(),
                    ),
                    IconButton(
                        icon: Icon(Icons.settings),
                        tooltip: 'Settings',
                        onPressed: _openSettingsPage,
                    ),
                    /* PopupMenuButton<int>(
                        onSelected: _onAppBarDropdownButtonChanged,
                        itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                                value: 0,
                                child: const Text('Solde')
                            ),
                            PopupMenuItem(
                                value: 1,
                                child: const Text('Show hidden expenses')
                            ),
                        ],
                    ) */
                ],
            ),
            body: ListView(
                children: ListTile.divideTiles(
                    context: context,
                    tiles: _expensesTiles()
                ).toList()
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: _openAddExpensePage,
                tooltip: 'Add expense',
                child: Icon(Icons.add),
            ), 
        );
    }

    Iterable<ListTile> _expensesTiles() {
        List<ListTile> tiles = [];
        for (ExpenseModel expense in _expenses) {
            if (!_showHiddenExpenses && expense.hide) {
                continue;
            }

            Icon leading = Icon(
                Icons.arrow_upward,
                color: Colors.green
            );

            if (expense.amount.isNegative) {
                leading = Icon(
                    Icons.arrow_downward,
                    color: Colors.red
                );
            }

            tiles.add(ListTile(
                leading: leading,
                title: Text(expense.amount.abs().toString()),
                subtitle: Text(expense.description),
                trailing: Text(DateFormat.Hm().format(expense.date)),
                onTap: _onEpenseTap(expense),
            ));
        }

        return tiles;
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

    void _openSettingsPage() {
        Navigator.pushNamed(context, Routes.SETTINGS)
        .then((result) {
            if (_showHiddenExpenses != (result as Map)['showHiddenExpenses']) {
                setState(() {
                    _showHiddenExpenses = !_showHiddenExpenses;
                });
            }
        })
        .catchError((e) {
            print(e);
        });
    }

    VoidCallback _onEpenseTap(ExpenseModel expense) {
        if (!_isToday()) {
            return null;
        }

        return () {
            Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdateExpensePage(expense.clone()),
                ),
            )
            .then((Map<String, dynamic> result) {
                if (result['code'] == 'updated') {
                    setState(() {
                        ExpenseModel e = result['data'];
                        expense.amount = e.amount;
                        expense.description = e.description;
                        expense.hide = e.hide;
                        expense.date = e.date;
                    });
                }
            })
            .catchError((e) {
                print(e);
            });
        };
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

    /* void _onAppBarDropdownButtonChanged(int value) {
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

        if (value == 1) {
            _changeVisibilityOfExpenses();
        }
    } */

    /* void _changeVisibilityOfExpenses() {
        setState(() {
            _showHiddenExpenses = !_showHiddenExpenses;
        });
    } */
}
