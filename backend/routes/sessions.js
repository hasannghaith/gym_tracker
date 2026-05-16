const express = require('express');
const router = express.Router();
const pool = require('../db');

// POST /api/sessions — Create a new session
router.post('/', async (req, res, next) => {
  try {
    const [result] = await pool.execute(
      'INSERT INTO sessions (started_at) VALUES (NOW())'
    );
    const [rows] = await pool.execute(
      'SELECT id, started_at, ended_at FROM sessions WHERE id = ?',
      [result.insertId]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// GET /api/sessions — List all sessions ordered by started_at DESC with exercise_count
router.get('/', async (req, res, next) => {
  try {
    const [rows] = await pool.execute(
      `SELECT s.id, s.started_at, s.ended_at,
              COUNT(e.id) AS exercise_count
       FROM sessions s
       LEFT JOIN exercises e ON e.session_id = s.id
       GROUP BY s.id
       ORDER BY s.started_at DESC`
    );
    // Ensure exercise_count is a number
    const sessions = rows.map(row => ({
      ...row,
      exercise_count: Number(row.exercise_count)
    }));
    res.json(sessions);
  } catch (err) {
    next(err);
  }
});

// GET /api/sessions/:id — Get session with nested exercises and sets
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    // Fetch the session
    const [sessionRows] = await pool.execute(
      'SELECT id, started_at, ended_at FROM sessions WHERE id = ?',
      [id]
    );

    if (sessionRows.length === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const session = sessionRows[0];

    // Fetch exercises for this session
    const [exerciseRows] = await pool.execute(
      'SELECT id, name FROM exercises WHERE session_id = ?',
      [id]
    );

    // Fetch sets for each exercise
    const exercises = [];
    for (const exercise of exerciseRows) {
      const [setRows] = await pool.execute(
        'SELECT id, reps, weight FROM workout_sets WHERE exercise_id = ?',
        [exercise.id]
      );
      exercises.push({
        id: exercise.id,
        name: exercise.name,
        sets: setRows.map(s => ({
          id: s.id,
          reps: s.reps,
          weight: Number(s.weight)
        }))
      });
    }

    session.exercises = exercises;
    res.json(session);
  } catch (err) {
    next(err);
  }
});

// PUT /api/sessions/:id — Update ended_at field
router.put('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { ended_at } = req.body;

    const [result] = await pool.execute(
      'UPDATE sessions SET ended_at = ? WHERE id = ?',
      [ended_at, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const [rows] = await pool.execute(
      'SELECT id, started_at, ended_at FROM sessions WHERE id = ?',
      [id]
    );
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// DELETE /api/sessions/:id — Delete session (cascade handled by DB)
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const [result] = await pool.execute(
      'DELETE FROM sessions WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    res.json({ message: 'Session deleted' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
