// index.js — Cloud Functions (Gen 2, Node 20)
// Exposes:
//   POST   /students           -> create/update a student
//   GET    /students/:id       -> fetch a student by ID

const express = require("express");
const cors = require("cors");
const { Firestore } = require("@google-cloud/firestore");

// Ignore undefined fields so Firestore never throws on missing keys
const db = new Firestore({ ignoreUndefinedProperties: true });

const app = express();
app.use(cors());                 // Access-Control-Allow-Origin: *
app.use(express.json());         // Parse application/json

// Health check
app.get("/", (_req, res) => res.status(200).send({ ok: true }));

// Create/Update student
app.post("/students", async (req, res) => {
  try {
    const { name = "", email = "", studentID = "", department = "" } = req.body || {};

    const trimmed = {
      name: String(name).trim(),
      email: String(email).trim(),
      studentID: String(studentID).trim(),
      department: String(department).trim(),
    };

    if (!trimmed.name || !trimmed.email || !trimmed.studentID || !trimmed.department) {
      return res.status(400).json({ message: "Missing required fields", body: trimmed });
    }

    await db.collection("students").doc(trimmed.studentID).set({
      name: trimmed.name,
      email: trimmed.email,
      department: trimmed.department,
      updatedAt: new Date().toISOString(),
    });

    return res.status(200).json({ ok: true, id: trimmed.studentID });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: "Error registering student.", error: String(err?.message || err) });
  }
});

// Retrieve student by ID
app.get("/students/:id", async (req, res) => {
  try {
    const id = String(req.params.id || "").trim();
    if (!id) return res.status(400).json({ message: "Student ID is required." });

    const snap = await db.collection("students").doc(id).get();
    if (!snap.exists) return res.status(404).json({ message: "Not found" });

    return res.status(200).json(snap.data());
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: "Error fetching student.", error: String(err?.message || err) });
  }
});

// Export the Express app as the function entry point
exports.registerStudent = app;
