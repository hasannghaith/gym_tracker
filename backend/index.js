require('dotenv').config();
const express = require('express');
const cors = require('cors');
const errorHandler = require('./middleware/errorHandler');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
const sessionsRoutes = require('./routes/sessions');
app.use('/api/sessions', sessionsRoutes);

const exercisesRoutes = require('./routes/exercises');
app.use('/api', exercisesRoutes);

const setsRoutes = require('./routes/sets');
app.use('/api', setsRoutes);

// 404 handler for undefined routes
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Global error handler (must be after all other middleware/routes)
app.use(errorHandler);

const PORT = process.env.PORT || 3000;

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;
