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
    String sql = 'SELECT * FROM ${DBFields.EXPENSE_TABLE_NAME} ORDER BY ${DBFields.EXPENSE_DATE} DESC';
    List args = [];

    if (date != null) {
        sql = 'SELECT * FROM ${DBFields.EXPENSE_TABLE_NAME} WHERE date(${DBFields.EXPENSE_DATE})=? ORDER BY ${DBFields.EXPENSE_DATE} DESC';
        args = [DateFormat('yyyy-MM-dd').format(date)];
    }

    _getDB()
    .then((Database db) {
        db.rawQuery(sql, args)
        .then((List<Map<String, dynamic>> _expenses) {
            List<ExpenseModel> expenses = [];

            _expenses.forEach((Map<String, dynamic> expense) {
                expenses.add(ExpenseModel.formMap(expense));
            });

            c.complete(expenses);
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
        db.rawQuery('SELECT * FROM ${DBFields.EXPENSE_TABLE_NAME} WHERE id=?', [id])
        .then((List<Map<String, dynamic>> expenses) {
            if (expenses.length != 1) {
                c.completeError(null);
                return;
            }

            c.complete(ExpenseModel.formMap(expenses[0]));
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
        db.rawQuery('SELECT date_ FROM ${DBFields.EXPENSE_TABLE_NAME} ORDER BY date_ ASC LIMIT 1')
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
        db.rawQuery('SELECT SUM(amount) AS solde FROM ${DBFields.EXPENSE_TABLE_NAME}')
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
    return db.execute('CREATE TABLE ${DBFields.EXPENSE_TABLE_NAME} (${DBFields.EXPENSE_ID} INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ${DBFields.EXPENSE_AMOUNT} DOUBLE NOT NULL, ${DBFields.EXPENSE_DESCRPTION} TEXT NOT NULL, ${DBFields.EXPENSE_DATE} DATETIME NOT NULL DEFAULT (datetime(\'now\', \'localtime\')), ${DBFields.EXPENSE_HIDE} INTERGER(1) CHECK(${DBFields.EXPENSE_HIDE} IN (0, 1)) NOT NULL DEFAULT 0)');
}

Future<int> addExpense(ExpenseModel expense) {
    Completer<int> c = new Completer();
    String sql = 'INSERT INTO ${DBFields.EXPENSE_TABLE_NAME}(amount, description) VALUES(?, ?)';
    List args = [expense.amount, expense.description];

    if (expense.hide) {
        sql = 'INSERT INTO ${DBFields.EXPENSE_TABLE_NAME}(amount, description, hide) VALUES(?, ?, 1)';
    }

    _getDB()
    .then((Database db) {
        db.rawInsert(sql, args)
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

Future<int> updateExpense(ExpenseModel expense) {
    Completer<int> c = new Completer();

    _getDB()
    .then((Database db) {
        db.rawUpdate('UPDATE ${DBFields.EXPENSE_TABLE_NAME} SET amount=?, description=? WHERE id=?', [expense.amount, expense.description, expense.id])
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
