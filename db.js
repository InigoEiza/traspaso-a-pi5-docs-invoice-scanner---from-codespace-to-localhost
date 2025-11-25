import knex from "knex";
import path from "path";
import dotenv from "dotenv";

dotenv.config();

// 📌 Ruta correcta en Raspberry Pi
const dbPath = path.resolve("./data/invoice_scanner.sqlite");

export const pool = knex({
  client: "sqlite3",
  connection: { filename: dbPath },
  useNullAsDefault: true,
});

console.log(`📌 Conectado a SQLite en ${dbPath}`);
