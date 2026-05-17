require('dotenv').config();
const express = require('express');
const cors = require('cors');
const errorHandler = require('./middleware/errorHandler');

const app = express();

app.use(cors());
app.use(express.json());

const sessionsRoutes = require('./routes/sessions');
app.use('/api/sessions', sessionsRoutes);

const exercisesRoutes = require('./routes/exercises');
app.use('/api', exercisesRoutes);

const setsRoutes = require('./routes/sets');
app.use('/api', setsRoutes);

app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

app.use(errorHandler);

const PORT = process.env.PORT || 3000;

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;
