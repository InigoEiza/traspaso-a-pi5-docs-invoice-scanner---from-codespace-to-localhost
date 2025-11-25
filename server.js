import "dotenv/config";
import express from "express";
import fileUpload from "express-fileupload";
import cors from "cors";
import { pool } from "./db.js";
import Tesseract from "tesseract.js";
import { router as configurationRoutes } from "../routes/configurations.js";
import {
  ensureResultadosTable,
  guardarResultado,
  obtenerResultados,
  generarCargaId,
  actualizarResultado,
  eliminarResultado,
} from "./resultados.js";

const app = express();

// CORS para acceso desde la red local
const allowedOrigins = [
  process.env.CORS_ORIGIN,
  "http://192.168.1.37:5175",
  "http://localhost:5175",
];

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin) return callback(null, true);
      if (allowedOrigins.includes(origin)) {
        console.log("CORS permitido:", origin);
        return callback(null, true);
      }
      console.warn("CORS bloqueado:", origin);
      callback(new Error("No autorizado por CORS"));
    },
    credentials: true,
  })
);

// Middleware
app.use(fileUpload());
app.use(express.json({ limit: "20mb" }));
app.use(express.urlencoded({ extended: true, limit: "20mb" }));

// Rutas de configuración
app.use("/api/configurations", configurationRoutes);

// Crear tabla resultados al iniciar
try {
  await ensureResultadosTable();
  console.log("Tabla 'resultados' lista.");
} catch (err) {
  console.error("Error tabla 'resultados':", err.message);
}

const cargaId = generarCargaId();
console.log(`Carga activa: ${cargaId}`);

// Health check
app.get("/api/health", async (_, res) => {
  try {
    const time = await pool.raw("SELECT datetime('now') as now");
    res.json({ ok: true, db: "SQLite", now: time[0].now });
  } catch (err) {
    res.status(500).json({ error: "Error BD" });
  }
});

// OCR
app.post("/api/ocr", async (req, res) => {
  try {
    const file = req.files?.file;
    if (!file) return res.status(400).json({ error: "No file" });
    const buffer = file.data;
    const lang = req.body.lang || "spa+eng";
    const result = await Tesseract.recognize(buffer, lang);
    res.json({ text: (result?.data?.text || "").trim() });
  } catch (err) {
    res.status(500).json({ error: "OCR error" });
  }
});

// Resultados
app.post("/api/resultados", async (req, res) => {
  try {
    const finalFileId = req.body.file_id || `FILE-${Date.now()}`;
    await guardarResultado({ ...req.body, carga_id: cargaId, file_id: finalFileId });
    res.json({ ok: true, file_id: finalFileId });
  } catch {
    res.status(500).json({ error: "Guardar error" });
  }
});

app.get("/api/resultados", async (_, res) => {
  try {
    res.json(await obtenerResultados());
  } catch {
    res.status(500).json({ error: "Obtener error" });
  }
});

app.put("/api/resultados/:id", async (req, res) => {
  try {
    await actualizarResultado(req.params.id, req.body);
    res.json({ ok: true });
  } catch {
    res.status(500).json({ error: "Actualizar error" });
  }
});

app.delete("/api/resultados/:id", async (req, res) => {
  try {
    await eliminarResultado(req.params.id);
    res.json({ ok: true });
  } catch {
    res.status(500).json({ error: "Eliminar error" });
  }
});

// Iniciar servidor
const PORT = process.env.PORT || 4000;
app.listen(PORT, "0.0.0.0", () =>
  console.log(`Backend en http://localhost:${PORT}`)
);
