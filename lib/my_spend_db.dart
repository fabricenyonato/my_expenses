import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import './types.dart';

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
            join(path, 'my_spend.db'),
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

Future<List<SpentModel>> getSpents() {
    Completer<List<SpentModel>> c = new Completer();

    _getDB()
    .then((Database db) {
        db.rawQuery('SELECT * FROM spent ORDER BY date_ DESC')
        .then((List<Map<String, dynamic>> _spending) {
            List<SpentModel> spending = [];

            _spending.forEach((Map<String, dynamic> _spent) {
                SpentModel spent = SpentModel();
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

Future<SpentModel> getSpentById(int id) {
    Completer<SpentModel> c = new Completer();

    _getDB()
    .then((Database db) {
        db.rawQuery('SELECT * FROM spent WHERE id=?', [id])
        .then((List<Map<String, dynamic>> spending) {
            if (spending.length != 1) {
                c.completeError(null);
                return;
            }

            final Map<String, dynamic> _spent = spending[0];
            SpentModel spent = SpentModel();
            spent.id = _spent['id'];
            spent.amount = _spent['amount'];
            spent.date = DateTime.parse(_spent['date_']);
            spent.description = _spent['description'].toString();

            c.complete(spent);
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
    return db.execute('CREATE TABLE spent (id INTEGER PRIMARY KEY AUTOINCREMENT, amount DOUBLE NOT NULL, description TEXT, date_ DATETIME DEFAULT (datetime(\'now\')))');
}

Future<int> addSpent(SpentModel spent) {
    Completer<int> c = new Completer();

    _getDB()
    .then((Database db) {
        db.rawInsert('INSERT INTO spent(amount, description) VALUES(?, ?)', [spent.amount, spent.description])
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

