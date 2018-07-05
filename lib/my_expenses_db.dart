import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import './utils.dart';

Future<Database> _getDB() {
    Completer<Database> c = new Completer();

    getDatabasesPath()
    .then((String path) {
        // deleteDatabase(path)
        // .then((r) {
        //     print(r);
        // })
        // .catchError((e) {
        //     print(e);
        // });

        openDatabase(
            join(path, 'my_expenses.db'),
            version: 1,
            onCreate: _createDB
        )
        .then((Database db) {
            c.complete(db);
        })
        .catchError((e) {
            c.completeError(e);
        });
    })
    .catchError((e) {
        c.completeError(e);
    });

    return c.future;
}

Future<List<ExpenseModel>> getExpenses({
    DateTime date
}) {
    Completer<List<ExpenseModel>> c = new Completer();
    String sql = 'SELECT * FROM ${DBTables.EXPENSE} ORDER BY date_ DESC';
    List args = [];

    if (date != null) {
        sql = 'SELECT * FROM ${DBTables.EXPENSE} WHERE date(date_)=? ORDER BY date_ DESC';
        args = [DateFormat('yyyy-MM-dd').format(date)];
    }

    _getDB()
    .then((Database db) {
        db.rawQuery(sql, args)
        .then((List<Map<String, dynamic>> _spending) {
            List<ExpenseModel> spending = [];

            _spending.forEach((Map<String, dynamic> _spent) {
                ExpenseModel spent = ExpenseModel();
                spent.id = _spent['id'];
                spent.amount = _spent['amount'];
                spent.date = DateTime.parse(_spent['date_']);
                spent.description = _spent['description'].toString();

                spending.add(spent);
            });

            c.complete(spending);
        })
        .catchError((e) {
            c.completeError(e);
        });
    })
    .catchError((e) {
        c.completeError(e);
    });

    return c.future;
}

Future<ExpenseModel> getExpenseById(int id) {
    Completer<ExpenseModel> c = new Completer();

    _getDB()
    .then((Database db) {
        db.rawQuery('SELECT * FROM ${DBTables.EXPENSE} WHERE id=?', [id])
        .then((List<Map<String, dynamic>> expenses) {
            if (expenses.length != 1) {
                c.completeError(null);
                return;
            }

            final Map<String, dynamic> _expense = expenses[0];
            ExpenseModel expense = ExpenseModel();
            expense.id = _expense['id'];
            expense.amount = _expense['amount'];
            expense.date = DateTime.parse(_expense['date_']);
            expense.description = _expense['description'].toString();

            c.complete(expense);
        })
        .catchError((e) {
            c.completeError(e);
        });
    })
    .catchError((e) {
        c.completeError(e);
    });

    return c.future;
}

Future<DateTime> getFirstExpenseDate() {
    Completer<DateTime> c = new Completer();

    _getDB()
    .then((Database db) {
        db.rawQuery('SELECT date_ FROM ${DBTables.EXPENSE} ORDER BY date_ ASC LIMIT 1')
        .then((List<Map<String, dynamic>> expenses) {
            if (expenses.length != 1) {
                c.completeError(null);
                return;
            }

            c.complete(DateTime.parse(expenses[0]['date_']));
        })
        .catchError((e) {
            c.completeError(e);
        });
    })
    .catchError((e) {
        c.completeError(e);
    });

    return c.future;
}

Future<double> getSolde() {
    Completer<double> c = new Completer();

    _getDB()
    .then((Database db) {
        db.rawQuery('SELECT SUM(amount) AS solde FROM ${DBTables.EXPENSE}')
        .then((List<Map<String, dynamic>> expenses) {
            if (expenses.length != 1) {
                c.completeError(null);
                return;
            }

            c.complete(expenses[0]['solde']);
        })
        .catchError((e) {
            c.completeError(e);
        });
    })
    .catchError((e) {
        c.completeError(e);
    });

    return c.future;
}

FutureOr _createDB (Database db, int version) {
    return db.execute('CREATE TABLE ${DBTables.EXPENSE} (id INTEGER PRIMARY KEY AUTOINCREMENT, amount DOUBLE NOT NULL, description TEXT, date_ DATETIME DEFAULT (datetime(\'now\')))');
}

Future<int> addExpense(ExpenseModel expense) {
    Completer<int> c = new Completer();

    _getDB()
    .then((Database db) {
        db.rawInsert('INSERT INTO ${DBTables.EXPENSE}(amount, description) VALUES(?, ?)', [expense.amount, expense.description])
        .then((id) {
            c.complete(id);
        })
        .catchError((e) {
            c.completeError(e);
        });
    })
    .catchError((e) {
        c.completeError(e);
    });

    return c.future;
}

