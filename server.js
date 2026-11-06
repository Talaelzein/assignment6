import taskRoutes from './routes/tasks.js';
import 'dotenv/config';
import express from 'express';
import db from './db/database.js';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use('/api/tasks', taskRoutes);

app.get('/', (req, res) => {
  res.json({
    message: 'Task Management API is running'
  });
});

// Database health check
app.get('/api/health', (req, res) => {
  try {
    const result = db.prepare('SELECT 1 AS connected').get();

    res.status(200).json({
      status: 'ok',
      database: result.connected === 1 ? 'connected' : 'error'
    });
  } catch (error) {
    console.error('Database health check failed:', error);

    res.status(500).json({
      error: 'Database connection failed'
    });
  }
});

// Handle requests to unknown routes
app.use((req, res) => {
  res.status(404).json({
    error: 'Route not found'
  });
});


// Handle malformed JSON and other request errors
app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      error: 'Invalid JSON in request body'
    });
  }

  console.error('Unhandled request error:', err);

  res.status(500).json({
    error: 'Internal server error'
  });
});


app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
