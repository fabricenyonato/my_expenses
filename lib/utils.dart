class ExpenseModel {
    int id;
    double amount = 0.0;
    String description;
    DateTime date;

    @override
    String toString() => '${runtimeType.toString()}(\n\tid: $id\n\tamount: $amount,\n\tdescription: $description\n\tdate: $date\n)';
}

enum ExpenseMeaning {
    EXITS,
    ENTERED
}

class DBTables {
    static const String EXPENSE = 'expense';

    DBTables._();
}

class Routes {
    static const String EXPENSES_PAGE = '/expenses';
    static const String ADD_EXPENSE_PAGE = '/add_expense';

    Routes._();
}
