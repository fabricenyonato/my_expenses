class ExpenseModel {
    int id;
    double amount;
    String description;
    DateTime date;
    bool hide = false;

    ExpenseModel();

    ExpenseModel.formMap(Map<String, dynamic> map) {
        id = map[DBFields.EXPENSE_ID];
        amount = map[DBFields.EXPENSE_AMOUNT];
        date = DateTime.parse(map[DBFields.EXPENSE_DATE]);
        hide = map[DBFields.EXPENSE_HIDE] == 1 ? true : false;
        description = map[DBFields.EXPENSE_DESCRPTION].toString();
    }

    @override
    String toString() => '${runtimeType.toString()}(\n\tid: $id\n\tamount: $amount,\n\tdescription: $description\n\tdate: $date,\n\thide: $hide\n)';

    ExpenseModel clone() {
        return (ExpenseModel())
        ..amount = amount
        ..date = date
        ..description = description
        ..hide = hide
        ..id = id;
    }
}

enum ExpenseMeaning {
    EXITS,
    ENTERED
}

class DBFields {
    static const String EXPENSE_TABLE_NAME = 'expense';
    static const String EXPENSE_ID = 'id';
    static const String EXPENSE_AMOUNT = 'amount';
    static const String EXPENSE_DATE = 'date_';
    static const String EXPENSE_DESCRPTION = 'description';
    static const String EXPENSE_HIDE = 'hide';

    DBFields._();
}

class Routes {
    static const String EXPENSES_PAGE = '/expenses';
    static const String ADD_EXPENSE_PAGE = '/add_expense';
    static const String SETTINGS = '/settings';

    Routes._();
}

class SettingKey {
    static const String SHOW_HIDDEN_EXPENSES = 'showHiddenExpenses';

    SettingKey._();
}
