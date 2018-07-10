CREATE TABLE expense (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    amount DOUBLE NOT NULL,
    description TEXT NOT NULL,
    date_ DATETIME NOT NULL DEFAULT (datetime('now', 'localtime')),
    hide INTERGER(1) CHECK(hide IN (0, 1)) NOT NULL DEFAULT 0
)