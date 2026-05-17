const express = require('express');
const router = express.Router({ mergeParams: true });
const pool = require('../db');

router.post('/exercises/:exerciseId/sets', async (req, res, next) => {
  try {
    const { exerciseId } = req.params;
    const { reps, weight } = req.body;

    if (reps === undefined || reps === null || weight === undefined || weight === null) {
      return res.status(400).json({ error: 'Reps and weight are required' });
    }

    const [exerciseRows] = await pool.execute(
      'SELECT id FROM exercises WHERE id = ?',
      [exerciseId]
    );

    if (exerciseRows.length === 0) {
      return res.status(404).json({ error: 'Exercise not found' });
    }

    const [result] = await pool.execute(
      'INSERT INTO workout_sets (exercise_id, reps, weight) VALUES (?, ?, ?)',
      [exerciseId, reps, weight]
    );

    res.status(201).json({
      id: result.insertId,
      exercise_id: Number(exerciseId),
      reps: reps,
      weight: Number(weight)
    });
  } catch (err) {
    next(err);
  }
});

router.get('/exercises/:exerciseId/sets', async (req, res, next) => {
  try {
    const { exerciseId } = req.params;

    const [rows] = await pool.execute(
      'SELECT id, exercise_id, reps, weight FROM workout_sets WHERE exercise_id = ?',
      [exerciseId]
    );

    const sets = rows.map(row => ({
      id: row.id,
      exercise_id: row.exercise_id,
      reps: row.reps,
      weight: Number(row.weight)
    }));

    res.json(sets);
  } catch (err) {
    next(err);
  }
});

router.put('/sets/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { reps, weight } = req.body;

    const [result] = await pool.execute(
      'UPDATE workout_sets SET reps = ?, weight = ? WHERE id = ?',
      [reps, weight, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Set not found' });
    }

    const [rows] = await pool.execute(
      'SELECT id, exercise_id, reps, weight FROM workout_sets WHERE id = ?',
      [id]
    );

    res.json({
      id: rows[0].id,
      exercise_id: rows[0].exercise_id,
      reps: rows[0].reps,
      weight: Number(rows[0].weight)
    });
  } catch (err) {
    next(err);
  }
});

router.delete('/sets/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const [result] = await pool.execute(
      'DELETE FROM workout_sets WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Set not found' });
    }

    res.json({ message: 'Set deleted' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
