import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { query } from "./db.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// ============================================
// HEALTH CHECK
// ============================================
app.get("/api/health", (req, res) => {
    res.json({ ok: true, message: "Backend funcionando" });
});

// ============================================
// CATEGORIES
// ============================================

// Get all categories
app.get("/api/categories", async (req, res) => {
    try {
        const result = await query(
            "SELECT id, name FROM categories WHERE user_id IS NOT NULL ORDER BY name"
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Create category
app.post("/api/categories", async (req, res) => {
    try {
        const { name, user_id = 1 } = req.body;
        const result = await query(
            "INSERT INTO categories (name, user_id) VALUES ($1, $2) RETURNING id, name",
            [name, user_id]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================
// WORDS
// ============================================

// Get all words
app.get("/api/words", async (req, res) => {
    try {
        const { category_id } = req.query;
        let queryText = `
            SELECT w.id, w.spanish, w.english, w.category_id, c.name as category_name
            FROM words w
            LEFT JOIN categories c ON w.category_id = c.id
        `;
        const params = [];

        if (category_id) {
            queryText += " WHERE w.category_id = $1";
            params.push(category_id);
        }
        queryText += " ORDER BY w.created_at DESC";

        const result = await query(queryText, params);
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Create word
app.post("/api/words", async (req, res) => {
    try {
        const { spanish, english, category_id, user_id = 1 } = req.body;
        const result = await query(
            "INSERT INTO words (spanish, english, category_id, user_id) VALUES ($1, $2, $3, $4) RETURNING *",
            [spanish, english, category_id, user_id]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get 20 random words for practice
app.get("/api/words/random", async (req, res) => {
    try {
        const result = await query(
            "SELECT id, spanish, english FROM words ORDER BY RANDOM() LIMIT 20"
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================
// EXERCISES
// ============================================

// Get exercises
app.get("/api/exercises", async (req, res) => {
    try {
        const result = await query(
            "SELECT id, sentence, answer, options FROM exercises ORDER BY created_at DESC LIMIT 20"
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Save exercises (batch)
app.post("/api/exercises", async (req, res) => {
    try {
        const { exercises, user_id = 1 } = req.body;

        // Delete old exercises first (optional, keeps only latest batch)
        await query("DELETE FROM exercises WHERE user_id = $1", [user_id]);

        // Insert new exercises
        const insertedExercises = [];
        for (const ex of exercises) {
            const result = await query(
                "INSERT INTO exercises (sentence, answer, options, user_id) VALUES ($1, $2, $3, $4) RETURNING *",
                [ex.sentence, ex.answer, JSON.stringify(ex.options), user_id]
            );
            insertedExercises.push(result.rows[0]);
        }

        res.status(201).json({
            message: `${insertedExercises.length} ejercicios guardados`,
            exercises: insertedExercises
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================
// PRACTICE SESSIONS
// ============================================

// Start practice session
app.post("/api/practice/start", async (req, res) => {
    try {
        const { user_id = 1 } = req.body;
        const result = await query(
            "INSERT INTO practice_sessions (user_id, total_questions) VALUES ($1, 0) RETURNING *",
            [user_id]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Submit answer
app.post("/api/practice/answer", async (req, res) => {
    try {
        const { session_id, exercise_id, user_answer, is_correct } = req.body;

        await query(
            "INSERT INTO practice_answers (session_id, exercise_id, user_answer, is_correct) VALUES ($1, $2, $3, $4)",
            [session_id, exercise_id, user_answer, is_correct]
        );

        // Update session stats
        await query(
            `UPDATE practice_sessions 
             SET total_questions = total_questions + 1,
                 correct_answers = correct_answers + $1
             WHERE id = $2`,
            [is_correct ? 1 : 0, session_id]
        );

        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// End practice session
app.post("/api/practice/end", async (req, res) => {
    try {
        const { session_id } = req.body;
        const result = await query(
            "UPDATE practice_sessions SET completed_at = NOW() WHERE id = $1 RETURNING *",
            [session_id]
        );
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("API en http://localhost:" + PORT));
