const express = require('express');
const router = express.Router({ mergeParams: true });
const pool = require('../db');

// POST /api/sessions/:sessionId/exercises — Create exercise in session
router.post('/sessions/:sessionId/exercises', async (req, res, next) => {
  try {
    const { sessionId } = req.params;
    const { name } = req.body;

    // Validate name field
    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Name is required' });
    }

    // Verify session exists
    const [sessionRows] = await pool.execute(
      'SELECT id FROM sessions WHERE id = ?',
      [sessionId]
    );

    if (sessionRows.length === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    // Insert exercise
    const [result] = await pool.execute(
      'INSERT INTO exercises (session_id, name) VALUES (?, ?)',
      [sessionId, name]
    );

    res.status(201).json({
      id: result.insertId,
      session_id: Number(sessionId),
      name: name
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/sessions/:sessionId/exercises — List exercises for session with their sets
router.get('/sessions/:sessionId/exercises', async (req, res, next) => {
  try {
    const { sessionId } = req.params;

    const [exerciseRows] = await pool.execute(
      'SELECT id, session_id, name FROM exercises WHERE session_id = ?',
      [sessionId]
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
        session_id: exercise.session_id,
        name: exercise.name,
        sets: setRows.map(s => ({
          id: s.id,
          reps: s.reps,
          weight: Number(s.weight)
        }))
      });
    }

    res.json(exercises);
  } catch (err) {
    next(err);
  }
});

// PUT /api/exercises/:id — Update exercise name
router.put('/exercises/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name } = req.body;

    const [result] = await pool.execute(
      'UPDATE exercises SET name = ? WHERE id = ?',
      [name, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Exercise not found' });
    }

    const [rows] = await pool.execute(
      'SELECT id, session_id, name FROM exercises WHERE id = ?',
      [id]
    );
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// DELETE /api/exercises/:id — Delete exercise (cascade handled by DB)
router.delete('/exercises/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const [result] = await pool.execute(
      'DELETE FROM exercises WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Exercise not found' });
    }

    res.json({ message: 'Exercise deleted' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
