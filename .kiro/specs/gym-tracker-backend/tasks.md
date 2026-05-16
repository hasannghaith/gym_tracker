# Implementation Plan: Gym Tracker Backend

## Overview

This plan implements a Node.js Express REST API backend with MySQL database, then integrates it into the existing Flutter Gym Tracker app. Tasks are ordered: backend setup first, then Flutter model updates, API service, UI integration, and finally the new History Screen.

## Tasks

- [x] 1. Set up backend project structure and dependencies
  - [x] 1.1 Initialize Node.js project with package.json
    - Create `backend/` directory
    - Create `package.json` with express, mysql2, cors, dotenv dependencies and jest, fast-check dev dependencies
    - Create `.env.example` with DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, PORT placeholders
    - Add `.env` to `.gitignore`
    - _Requirements: 1.1, 1.2_

  - [x] 1.2 Create database connection pool module
    - Create `backend/db.js` that exports a mysql2 promise pool configured from environment variables
    - _Requirements: 2.6_

  - [x] 1.3 Create Express entry point with middleware
    - Create `backend/index.js` with Express app setup
    - Configure CORS middleware and JSON body parsing
    - Add a catch-all 404 handler for undefined routes that returns `{ "error": "Not found" }` with 404 status
    - Start server on PORT from environment
    - _Requirements: 1.1, 1.2, 1.4, 1.5_

  - [x] 1.4 Create global error handler middleware
    - Create `backend/middleware/errorHandler.js`
    - Catch unhandled errors, log them, and return a 500 JSON response with `{ "error": "Internal server error" }`
    - Wire into Express app in index.js
    - _Requirements: 1.4_

- [x] 2. Implement Session API routes
  - [x] 2.1 Create sessions route module with CRUD operations
    - Create `backend/routes/sessions.js`
    - POST `/api/sessions` — insert new session with current timestamp, return 201 with created session
    - GET `/api/sessions` — select all sessions ordered by started_at DESC, include exercise_count
    - GET `/api/sessions/:id` — select session with nested exercises and their sets, return 404 if not found
    - PUT `/api/sessions/:id` — update ended_at field, return 404 if not found
    - DELETE `/api/sessions/:id` — delete session (cascade handled by DB), return 404 if not found
    - Mount routes in index.js
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [ ]* 2.2 Write property tests for session routes
    - **Property 4: Create Operations Return Correct Resource** — POST /api/sessions returns 201 with id and started_at
    - **Property 5: Sessions List Is Sorted Descending** — GET /api/sessions returns sessions ordered by started_at DESC
    - **Property 9: Non-Existent Resource References Return 404** — GET/PUT/DELETE with non-existent id returns 404
    - **Validates: Requirements 3.1, 3.2, 3.6**

- [x] 3. Implement Exercise API routes
  - [x] 3.1 Create exercises route module with CRUD operations
    - Create `backend/routes/exercises.js`
    - POST `/api/sessions/:sessionId/exercises` — validate name field (400 if missing), verify session exists (404 if not), insert exercise, return 201
    - GET `/api/sessions/:sessionId/exercises` — select exercises for session with their sets
    - PUT `/api/exercises/:id` — update exercise name, return 404 if not found
    - DELETE `/api/exercises/:id` — delete exercise (cascade), return 404 if not found
    - Mount routes in index.js
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

  - [x] 3.2 Write property tests for exercise routes
    - **Property 4: Create Operations Return Correct Resource** — POST exercises returns 201 with id, session_id, and name
    - **Property 10: Missing Required Fields Return 400** — POST without name returns 400
    - **Property 9: Non-Existent Resource References Return 404** — POST to non-existent session returns 404
    - **Validates: Requirements 4.1, 4.5, 4.6**

- [x] 4. Implement Workout Set API routes
  - [x] 4.1 Create sets route module with CRUD operations
    - Create `backend/routes/sets.js`
    - POST `/api/exercises/:exerciseId/sets` — validate reps and weight fields (400 if missing), verify exercise exists (404 if not), insert set, return 201
    - GET `/api/exercises/:exerciseId/sets` — select all sets for exercise
    - PUT `/api/sets/:id` — update reps and weight, return 404 if not found
    - DELETE `/api/sets/:id` — delete set, return 404 if not found
    - Mount routes in index.js
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

  - [ ]* 4.2 Write property tests for set routes
    - **Property 4: Create Operations Return Correct Resource** — POST sets returns 201 with id, exercise_id, reps, weight
    - **Property 10: Missing Required Fields Return 400** — POST without reps or weight returns 400
    - **Property 9: Non-Existent Resource References Return 404** — POST to non-existent exercise returns 404
    - **Validates: Requirements 5.1, 5.5, 5.6**

- [x] 5. Checkpoint - Backend API complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Create MySQL database schema
  - [x] 6.1 Create SQL initialization script
    - Create `backend/schema.sql` with CREATE TABLE statements for sessions, exercises, and workout_sets
    - Include foreign key constraints with ON DELETE CASCADE
    - Include IF NOT EXISTS clauses for idempotent execution
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

- [x] 7. Update Flutter data models with JSON serialization
  - [x] 7.1 Rewrite models.dart with id fields and JSON methods
    - Update `WorkoutSet` class: add `id` (int?), `exerciseId` (int?), change `reps` to int, `weight` to double, add `fromJson`/`toJson`
    - Update `Exercise` class: add `id` (int?), `sessionId` (int?), add `fromJson`/`toJson`
    - Create `Session` class: with `id` (int?), `startedAt` (DateTime), `endedAt` (DateTime?), `exercises` list, add `fromJson`/`toJson`
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ]* 7.2 Write property test for model serialization round-trip
    - **Property 1: Model Serialization Round-Trip** — For any valid Session, Exercise, or WorkoutSet, toJson then fromJson produces equivalent object
    - **Validates: Requirements 8.5**

- [x] 8. Create Flutter API service
  - [x] 8.1 Add http dependency to pubspec.yaml
    - Add `http: ^1.2.2` to dependencies section
    - _Requirements: 6.1_

  - [x] 8.2 Implement ApiService class
    - Create `lib/api_service.dart` with singleton pattern
    - Implement session methods: createSession, getSessions, getSession, endSession, deleteSession
    - Implement exercise methods: createExercise, getExercises, updateExercise, deleteExercise
    - Implement set methods: createSet, getSets, updateSet, deleteSet
    - Add 10-second timeout to all requests
    - Throw descriptive exceptions on non-2xx responses
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_

- [x] 9. Integrate API service into GymScreen
  - [x] 9.1 Update gym_screen.dart to use ApiService
    - Call `ApiService.createSession()` when user starts a session
    - Call `ApiService.createExercise()` when user adds an exercise
    - Call `ApiService.createSet()` when user adds a set
    - Call `ApiService.deleteExercise()` when user removes an exercise
    - Call `ApiService.endSession()` when user ends a session
    - Show SnackBar error messages when API calls fail
    - Store session/exercise/set IDs from API responses in local state
    - _Requirements: 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_

- [x] 10. Implement History Screen
  - [x] 10.1 Create history_screen.dart
    - Create `lib/history_screen.dart` as a StatefulWidget
    - Fetch all sessions from API on screen load
    - Display sessions in a list with date and exercise count
    - Show empty state message when no sessions exist
    - Implement tap-to-view session detail (show exercises and sets)
    - Implement delete session with confirmation and API call
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

  - [x] 10.2 Update gym_app.dart with navigation to History Screen
    - Add route or navigation mechanism to reach History Screen from main screen
    - Add a navigation button (e.g., history icon in AppBar) to GymScreen
    - _Requirements: 7.1_

- [x] 11. Checkpoint - Full integration complete
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 12. Write backend integration tests for cascade delete
  - **Property 8: Delete Operations Cascade to Children** — Deleting a session removes its exercises and sets; deleting an exercise removes its sets
  - **Property 7: Update Operations Persist Changes** — PUT then GET returns updated values
  - **Validates: Requirements 3.5, 4.4, 5.4, 3.4, 4.3, 5.3**

- [x] 13. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Backend tasks (1-6) should be completed before Flutter integration tasks (7-10)
- The database schema script (task 6) should be run manually on the hosted MySQL instance before testing
