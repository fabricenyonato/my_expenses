class SpentModel {
    int id = 0;
    double amount = 0.0;
    String description = '';
    DateTime date;

    @override
    String toString() => 'SpentModel(\n\tid: $id\n\tamount: $amount,\n\tdescription: $description\n\tdate: $date\n)';
}

enum SpentMeaning {
    exits,
    entered
}
