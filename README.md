
# Task Management REST API

## Project Overview

This project is a RESTful Task Management API developed for Web Programming Assignment 6.

The application uses Node.js, Express.js, and SQLite to manage tasks through standard HTTP requests. It supports all CRUD operations (Create, Read, Update, Delete), validates incoming data, returns appropriate HTTP status codes, and provides meaningful JSON error responses.

All tasks are stored in a persistent SQLite database, allowing records to remain available after the server restarts.

## Technologies Used

- Node.js (version 24 or later)
- Express.js
- SQLite (built-in `node:sqlite` module)
- dotenv for environment configuration
- PowerShell for automated API testing

## Features

- Create a new task
- Retrieve all tasks
- Retrieve a single task by ID
- Update an existing task
- Delete an existing task
- Validate task IDs and request bodies
- Return appropriate HTTP status codes
- Handle errors with JSON responses
- Store data persistently in SQLite
- Automatically create the database and table
- Check database connectivity
- Run automated tests for API functionality and validation

## Installation and Setup

### Prerequisites

Install:

- Node.js version 24 or later
- npm (included with Node.js)

Verify your installation:

```bash
node --version
npm --version
```

### 1. Clone the repository

```bash
git clone https://github.com/Talaelzein/assignment6.git
cd assignment6
```

Alternatively, extract the submitted ZIP file and open a terminal in the `assignment6` directory.

### 2. Install dependencies

```bash
npm install
```
This installs the packages listed in `package.json`, including Express and dotenv.
For a reproducible installation using `package-lock.json`, you may use:

```bash
npm ci
```
On Windows PowerShell, use `npm.cmd` instead of `npm` if PowerShell script execution is restricted.

### 3. Configure environment variables

The repository includes an `.env.example` file containing:

```env
PORT=3000
DATABASE_PATH=./data/tasks.db
```

Create a `.env` file in the project root with the same contents.

On Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

On macOS/Linux:

```bash
cp .env.example .env
```

The application also provides fallback values if these variables are not set.

The `.env` file is excluded from Git using `.gitignore`.

### 4. Start the server

Development mode (automatically restarts when source files change):

```bash
npm run dev
```

Normal mode:

```bash
npm start
```

On Windows PowerShell, the equivalent commands are:

```powershell
npm.cmd run dev
npm.cmd start
```

The server will display:

```text
Server running at http://localhost:3000
```

The API is accessible at:

http://localhost:3000

The SQLite database is stored at `data/tasks.db` by default.

The application automatically creates the database directory, database file, and tasks table when necessary.

## Database Structure

The application uses a SQLite database containing a `tasks` table.

| Field | Type | Description |
|---|---|---|
| `id` | INTEGER | Unique identifier; primary key with automatic increment |
| `title` | TEXT | Required, non-empty task title |
| `description` | TEXT | Task description, defaulting to an empty string |
| `completed` | INTEGER | Completion status: `0` = incomplete, `1` = completed |
| `created_at` | TEXT | Automatically generated creation timestamp |

The database schema is initialized automatically in `db/database.js`.

### Input Data Rules

When creating a task using POST:

- `title` is required and must be a non-empty string.
- `description` is optional and defaults to an empty string.
- `completed` is optional and defaults to `false`.

When updating a task using PUT:

- `title` is required.
- `description` is required and must be a string.
- `completed` is required and must be a boolean.

The `completed` field must use JSON boolean values (`true` or `false`) in requests.

The API stores and returns the completion status as an integer (`0` or `1`).

Task titles are trimmed before being saved. Descriptions are also trimmed.

## API Endpoints

Base URL:

```text
http://localhost:3000
```

### Endpoint Summary

| Method | Endpoint | Description | Success Code |
|---|---|---|---|
| GET | `/` | Check whether the API is running | 200 |
| GET | `/api/health` | Check SQLite connectivity | 200 |
| GET | `/api/tasks` | Retrieve all tasks | 200 |
| GET | `/api/tasks/:id` | Retrieve a specific task | 200 |
| POST | `/api/tasks` | Create a new task | 201 |
| PUT | `/api/tasks/:id` | Update an existing task | 200 |
| DELETE | `/api/tasks/:id` | Delete a task | 200 |

### 1. GET /

Check whether the API server is running.

**Success status:** `200 OK`

Example request:

```http
GET /
```

Example response:

```json
{
  "message": "Task Management API is running"
}
```

No request body is required.

### 2. GET /api/health

Check whether the API can communicate with SQLite.

**Success status:** `200 OK`

Example request:

```http
GET /api/health
```

Example response:

```json
{
  "status": "ok",
  "database": "connected"
}
```

A database query failure returns HTTP `500` with a JSON error message.

### 3. GET /api/tasks

Retrieve all stored tasks.

**Success status:** `200 OK`

Example request:

```http
GET /api/tasks
```

Example response:

```json
[
  {
    "id": 1,
    "title": "Study Web Programming",
    "description": "Complete Assignment 6",
    "completed": 0,
    "created_at": "2026-11-05 17:33:50"
  }
]
```

Tasks are returned in descending order by ID.

If the database contains no tasks, the API returns an empty array:

```json
[]
```

### 4. GET /api/tasks/:id

Retrieve a single task using its ID.

**Success status:** `200 OK`

Example request:

```http
GET /api/tasks/1
```

Example response:

```json
{
  "id": 1,
  "title": "Study Web Programming",
  "description": "Complete Assignment 6",
  "completed": 0,
  "created_at": "2026-11-05 17:33:50"
}
```

Possible errors:

- `400 Bad Request`: Invalid task ID
- `404 Not Found`: Task does not exist
- `500 Internal Server Error`: Database or server failure

### 5. POST /api/tasks

Create a new task.

**Success status:** `201 Created`

Example request:

```http
POST /api/tasks
Content-Type: application/json
```

Request body:

```json
{
  "title": "Finish Assignment 6",
  "description": "Complete the REST API",
  "completed": false
}
```

Example response:

```json
{
  "id": 2,
  "title": "Finish Assignment 6",
  "description": "Complete the REST API",
  "completed": 0,
  "created_at": "2026-11-05 18:00:00"
}
```

The ID and creation timestamp are generated automatically.

Only the `title` field is mandatory when creating a task.

For example, this is also a valid request:

```json
{
  "title": "New task"
}
```

In that case, the API automatically assigns:

- `description`: `""`
- `completed`: `0`

Possible errors:

- `400 Bad Request`: Invalid or missing fields
- `400 Bad Request`: Malformed JSON
- `500 Internal Server Error`: Database or server failure

### 6. PUT /api/tasks/:id

Update all editable fields of an existing task.

**Success status:** `200 OK`

Example request:

```http
PUT /api/tasks/2
Content-Type: application/json
```

Request body:

```json
{
  "title": "Assignment 6 Completed",
  "description": "All endpoints tested",
  "completed": true
}
```

Example response:

```json
{
  "id": 2,
  "title": "Assignment 6 Completed",
  "description": "All endpoints tested",
  "completed": 1,
  "created_at": "2026-11-05 18:00:00"
}
```

All three editable fields (`title`, `description`, `completed`) must be supplied.

The task ID and creation timestamp remain unchanged.

Possible errors:

- `400 Bad Request`: Invalid ID or invalid request fields
- `404 Not Found`: Task does not exist
- `500 Internal Server Error`: Database or server failure

### 7. DELETE /api/tasks/:id

Delete an existing task.

**Success status:** `200 OK`

Example request:

```http
DELETE /api/tasks/2
```

Example response:

```json
{
  "message": "Task deleted successfully"
}
```

Possible errors:

- `400 Bad Request`: Invalid task ID
- `404 Not Found`: Task does not exist
- `500 Internal Server Error`: Database or server failure

Once deleted, the task is no longer available through the GET endpoints.

## HTTP Status Codes

The API uses standard HTTP response codes.

| Code | Meaning | Example |
|---|---|---|
| 200 OK | Request completed successfully | GET, PUT, DELETE |
| 201 Created | A new task was created | POST |
| 400 Bad Request | Invalid input, ID, or JSON | Invalid POST or PUT |
| 404 Not Found | Task or route does not exist | GET unknown task |
| 500 Internal Server Error | Unexpected server or database error | Database failure |

## Input Validation and Error Handling

The API validates input before inserting or updating database records.

### Invalid Title

An empty or missing title returns:

**Status:** `400 Bad Request`

```json
{
  "error": "Title is required and must be a non-empty string"
}
```

### Invalid Description

A description that is not a string returns:

**Status:** `400 Bad Request`

```json
{
  "error": "Description must be a string"
}
```

### Invalid Completed Value

A completed value that is not a JSON boolean returns:

**Status:** `400 Bad Request`

```json
{
  "error": "Completed must be a boolean"
}
```

### Invalid Task ID

A task ID that is not a positive integer returns:

**Status:** `400 Bad Request`

```json
{
  "error": "Task ID must be a positive integer"
}
```

### Task Not Found

A request for a nonexistent task returns:

**Status:** `404 Not Found`

```json
{
  "error": "Task not found"
}
```

### Unknown Route

A request to an undefined API route returns:

**Status:** `404 Not Found`

```json
{
  "error": "Route not found"
}
```

### Malformed JSON

A request containing invalid JSON returns:

**Status:** `400 Bad Request`

```json
{
  "error": "Invalid JSON in request body"
}
```

### Unexpected Server Errors

Unexpected errors are handled with HTTP `500` and a JSON error response.

The API also logs server-side errors for debugging.

Validation failures do not modify existing tasks.

## Manual API Testing with curl

The following examples use Bash-compatible curl syntax.

Start the server before running these commands.

**Note:** These examples use `localhost:3000`. Replace the sample task IDs with IDs returned by POST or GET requests.

### Check Server Status

```bash
curl -i http://localhost:3000/
```

### Check Database Health

```bash
curl -i http://localhost:3000/api/health
```

### Retrieve All Tasks

```bash
curl -i http://localhost:3000/api/tasks
```

### Create a Task

```bash
curl -i -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test task","description":"Testing POST","completed":false}'
```

The response includes the new task's ID. Use that ID for the following requests.

### Retrieve One Task

Example using ID `1`:

```bash
curl -i http://localhost:3000/api/tasks/1
```

### Update a Task

```bash
curl -i -X PUT http://localhost:3000/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Updated task","description":"Testing PUT","completed":true}'
```

### Delete a Task

```bash
curl -i -X DELETE http://localhost:3000/api/tasks/1
```

### Test a Nonexistent Task

```bash
curl -i http://localhost:3000/api/tasks/999999
```

Expected status: `404 Not Found`, assuming that task ID does not exist.

### Test an Invalid ID

```bash
curl -i http://localhost:3000/api/tasks/abc
```

Expected status: `400 Bad Request`.

### Test an Invalid POST Request

```bash
curl -i -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"","description":"Invalid task","completed":false}'
```

Expected status: `400 Bad Request`.

For Windows PowerShell users, the automated PowerShell test script described below provides a convenient alternative to Bash-style curl commands.

## Automated API Testing

The project includes an automated PowerShell testing script located at:

```text
tests/api-tests.ps1
```

The script sends HTTP requests to the running Express server and verifies response status codes, JSON response data, validation behavior, and database connectivity.

### How to Run the Tests

1. Install the dependencies.
2. Configure `.env` if necessary.
3. Start the Express server.
4. Open a separate PowerShell terminal in the project root.
5. Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tests\api-tests.ps1"
```

### Save the Test Results

To run the tests and save the terminal output:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tests\api-tests.ps1" 2>&1 | Tee-Object -FilePath ".\tests\api-test-results.txt"
```

### Test Coverage

The automated test script contains 22 checks, covering:

- Retrieve all tasks
- Create a task
- Retrieve a task by ID
- Update a task
- Validate returned task data
- Reject invalid POST and PUT requests
- Verify invalid updates do not modify tasks
- Handle nonexistent tasks
- Reject invalid task IDs
- Reject malformed JSON
- Reject missing titles
- Reject invalid description types
- Reject invalid completion values
- Reject incomplete PUT requests
- Handle unknown endpoints
- Handle PUT requests for missing tasks
- Handle DELETE requests for missing tasks
- Apply default values during task creation
- Delete tasks successfully
- Confirm that deleted tasks are unavailable
- Check SQLite database connectivity

### Test Evidence

The saved test report is included in:

```text
tests/api-test-results.txt
```

The latest local test run completed successfully:

```text
22/22 API TESTS PASSED!
```

The test script can be rerun to verify the API independently.

## Data Persistence

Tasks are stored in SQLite rather than application memory.

The database is initialized automatically when the application starts.

Records remain stored when the server is stopped and restarted.

The default database location is:

```text
data/tasks.db
```

The local database file is excluded from version control.

When someone clones the repository or extracts the submission ZIP, the application creates a new database automatically upon startup.

## Project Structure

```text
assignment6/
├── db/
│   └── database.js
├── routes/
│   └── tasks.js
├── tests/
│   ├── api-tests.ps1
│   └── api-test-results.txt
├── server.js
├── .env.example
├── .gitignore
├── package.json
├── package-lock.json
└── README.md
```

The `data/` directory and SQLite database are generated automatically if they do not exist.

The `node_modules/` directory is generated when installing dependencies.

The `.env` file, dependency directory, and local database files are excluded from Git.

## Security and Configuration

- Environment variables are managed using dotenv.
- The `.env` file is excluded from version control.
- SQL queries use prepared statements and parameter placeholders.
- User input is validated before database operations.
- Database errors are handled without exposing internal details in API responses.

## Assignment Deliverables

The submission includes:

1. A dedicated GitHub repository for Assignment 6.
2. The complete Node.js/Express source code.
3. SQLite database initialization code.
4. `package.json` and `package-lock.json`.
5. An `.env.example` configuration file.
6. This README with setup instructions, endpoint documentation, and examples.
7. Automated PowerShell API tests.
8. A saved test-results report demonstrating the API checks.
9. A ZIP archive of the project excluding `node_modules`, `.env`, and local database files.

## Author

Tala El Zein - 242297

Web Programming — Assignment 6
