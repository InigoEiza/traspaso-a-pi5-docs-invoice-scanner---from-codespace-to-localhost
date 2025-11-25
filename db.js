import knex from "knex";
import path from "path";
import dotenv from "dotenv";

dotenv.config();

// 🚀 Fuerza ruta absoluta a la base de datos principal
const dbPath = path.resolve("/workspaces/invoice-scanner/invoice_scanner.sqlite");

export const pool = knex({
  client: process.env.DB_CLIENT || "sqlite3",
  connection: { filename: dbPath },
  useNullAsDefault: true,
});

console.log(`✅ Conectado a SQLite en ${dbPath}`);
