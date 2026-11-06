import 'dotenv/config';
import { DatabaseSync } from 'node:sqlite';
import fs from 'node:fs';
import path from 'node:path';

const databasePath = path.resolve(
  process.env.DATABASE_PATH || './data/tasks.db'
);

// Create the folder for the database
fs.mkdirSync(path.dirname(databasePath), {
  recursive: true
});

// Open or create the SQLite database
const db = new DatabaseSync(databasePath);

// Create the tasks table
db.exec(`
  CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    completed INTEGER NOT NULL DEFAULT 0 CHECK (completed IN (0, 1)),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  )
`);

export default db;
