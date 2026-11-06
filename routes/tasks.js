
import express from 'express';
import db from '../db/database.js';

const router = express.Router();

// GET /api/tasks - Retrieve all tasks
router.get('/', (req, res) => {
  try {
    const tasks = db.prepare(
      'SELECT * FROM tasks ORDER BY id DESC'
    ).all();

    res.status(200).json(tasks);
  } catch (error) {
    console.error('Error retrieving tasks:', error);

    res.status(500).json({
      error: 'Failed to retrieve tasks'
    });
  }
});

// GET /api/tasks/:id - Retrieve a single task
router.get('/:id', (req, res) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isSafeInteger(id) || id <= 0) {
      return res.status(400).json({
        error: 'Task ID must be a positive integer'
      });
    }

    const task = db.prepare(
      'SELECT * FROM tasks WHERE id = ?'
    ).get(id);

    if (!task) {
      return res.status(404).json({
        error: 'Task not found'
      });
    }

    res.status(200).json(task);
  } catch (error) {
    console.error('Error retrieving task:', error);

    res.status(500).json({
      error: 'Failed to retrieve task'
    });
  }
});

 // POST /api/tasks - Create a new task
router.post('/', (req, res) => {
  try {
    const { title, description = '', completed = false } = req.body ?? {};

    // Validate the title
    if (typeof title !== 'string' || title.trim().length === 0) {
      return res.status(400).json({
        error: 'Title is required and must be a non-empty string'
      });
    }

    // Validate the description
    if (typeof description !== 'string') {
      return res.status(400).json({
        error: 'Description must be a string'
      });
    }

    // Validate completed
    if (typeof completed !== 'boolean') {
      return res.status(400).json({
        error: 'Completed must be a boolean'
      });
    }

    // Insert the new task into the database
    const result = db.prepare(`
      INSERT INTO tasks (title, description, completed)
      VALUES (?, ?, ?)
    `).run(
      title.trim(),
      description.trim(),
      completed ? 1 : 0
    );

    // Retrieve the newly created task
    const newTask = db.prepare(
      'SELECT * FROM tasks WHERE id = ?'
    ).get(Number(result.lastInsertRowid));

    res.status(201).json(newTask);
  } catch (error) {
    console.error('Error creating task:', error);

    res.status(500).json({
      error: 'Failed to create task'
    });
  }
});

// PUT /api/tasks/:id - Update an existing task
router.put('/:id', (req, res) => {
  try {
    const id = Number(req.params.id);

    // Validate the task ID
    if (!Number.isSafeInteger(id) || id <= 0) {
      return res.status(400).json({
        error: 'Task ID must be a positive integer'
      });
    }

    // Check if the task exists
    const existingTask = db.prepare(
      'SELECT * FROM tasks WHERE id = ?'
    ).get(id);

    if (!existingTask) {
      return res.status(404).json({
        error: 'Task not found'
      });
    }

    const { title, description, completed } = req.body ?? {};

    // PUT requires all task fields
    if (typeof title !== 'string' || title.trim().length === 0) {
      return res.status(400).json({
        error: 'Title is required and must be a non-empty string'
      });
    }

    if (typeof description !== 'string') {
      return res.status(400).json({
        error: 'Description must be a string'
      });
    }

    if (typeof completed !== 'boolean') {
      return res.status(400).json({
        error: 'Completed must be a boolean'
      });
    }

    // Update the database
    db.prepare(`
      UPDATE tasks
      SET title = ?, description = ?, completed = ?
      WHERE id = ?
    `).run(
      title.trim(),
      description.trim(),
      completed ? 1 : 0,
      id
    );

    // Return the updated record
    const updatedTask = db.prepare(
      'SELECT * FROM tasks WHERE id = ?'
    ).get(id);

    res.status(200).json(updatedTask);
  } catch (error) {
    console.error('Error updating task:', error);

    res.status(500).json({
      error: 'Failed to update task'
    });
  }
});

 // DELETE /api/tasks/:id - Delete an existing task
router.delete('/:id', (req, res) => {
  try {
    const id = Number(req.params.id);

    // Validate the task ID
    if (!Number.isSafeInteger(id) || id <= 0) {
      return res.status(400).json({
        error: 'Task ID must be a positive integer'
      });
    }

    // Check whether the task exists
    const existingTask = db.prepare(
      'SELECT * FROM tasks WHERE id = ?'
    ).get(id);

    if (!existingTask) {
      return res.status(404).json({
        error: 'Task not found'
      });
    }

    // Delete the task from the database
    db.prepare(
      'DELETE FROM tasks WHERE id = ?'
    ).run(id);

    // Confirm successful deletion
    res.status(200).json({
      message: 'Task deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting task:', error);

    res.status(500).json({
      error: 'Failed to delete task'
    });
  }
});

export default router;
