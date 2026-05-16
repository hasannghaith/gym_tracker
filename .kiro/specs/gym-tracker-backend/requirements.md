# Requirements Document

## Introduction

This feature adds a Node.js (Express) REST API backend with an online MySQL database to the existing Flutter Gym Tracker app. The app currently operates entirely in-memory with no data persistence. This enhancement enables full CRUD operations for workout sessions, exercises, and sets through a publicly accessible API, fulfilling the CSCI410 Mobile Application Development Project 2 requirements. A second screen (workout history) will be added to the Flutter app to meet the multi-screen requirement.

## Glossary

- **Backend**: The Node.js Express server that exposes REST API endpoints and communicates with the MySQL database
- **API**: The REST API layer that accepts HTTP requests from the Flutter app and returns JSON responses
- **Database**: The online MySQL database that stores all workout data persistently
- **Flutter_App**: The existing Flutter mobile application that serves as the frontend client
- **Session**: A workout session representing a single gym visit with a start time and optional end time
- **Exercise**: A named physical exercise (e.g., Bench Press) belonging to a session
- **Workout_Set**: A single set within an exercise, consisting of a repetition count and weight value
- **History_Screen**: The second screen in the Flutter app that displays past workout sessions
- **API_Service**: The Dart service class in the Flutter app responsible for making HTTP requests to the Backend

## Requirements

### Requirement 1: Backend Server Setup

**User Story:** As a developer, I want a Node.js Express server deployed to a public hosting platform, so that the Flutter app can access the API from any device.

#### Acceptance Criteria

1. THE Backend SHALL expose a REST API accessible via a public HTTPS URL
2. THE Backend SHALL use Node.js with the Express framework
3. THE Backend SHALL be deployed to an online hosting platform (Render, Railway, or equivalent)
4. WHEN the Backend receives a request, THE Backend SHALL respond with JSON-formatted data
5. WHEN the Backend receives a request with an invalid route, THE Backend SHALL return a 404 status code with an error message

### Requirement 2: Database Schema Design

**User Story:** As a developer, I want a properly normalized MySQL database schema, so that workout data is stored efficiently and maintains referential integrity.

#### Acceptance Criteria

1. THE Database SHALL contain a sessions table with columns for id (primary key, auto-increment), started_at (timestamp), and ended_at (nullable timestamp)
2. THE Database SHALL contain an exercises table with columns for id (primary key, auto-increment), session_id (foreign key referencing sessions), and name (varchar)
3. THE Database SHALL contain a workout_sets table with columns for id (primary key, auto-increment), exercise_id (foreign key referencing exercises), reps (integer), and weight (decimal)
4. THE Database SHALL enforce foreign key constraints between exercises and sessions
5. THE Database SHALL enforce foreign key constraints between workout_sets and exercises
6. THE Database SHALL be hosted on an online MySQL hosting service (Railway, FreeSQLDatabase, or equivalent)

### Requirement 3: Session API Endpoints

**User Story:** As a user, I want to create and retrieve workout sessions through the API, so that my gym visits are recorded and accessible.

#### Acceptance Criteria

1. WHEN a POST request is sent to /api/sessions, THE API SHALL create a new session record with the current timestamp as started_at and return the created session with a 201 status code
2. WHEN a GET request is sent to /api/sessions, THE API SHALL return a JSON array of all sessions ordered by started_at descending
3. WHEN a GET request is sent to /api/sessions/:id, THE API SHALL return the session with its associated exercises and workout sets
4. WHEN a PUT request is sent to /api/sessions/:id with an ended_at value, THE API SHALL update the session end time and return the updated session
5. WHEN a DELETE request is sent to /api/sessions/:id, THE API SHALL delete the session and all associated exercises and workout sets (cascade delete) and return a 200 status code
6. IF a request references a session id that does not exist, THEN THE API SHALL return a 404 status code with an error message

### Requirement 4: Exercise API Endpoints

**User Story:** As a user, I want to create, read, update, and delete exercises within a session, so that I can manage my workout exercises.

#### Acceptance Criteria

1. WHEN a POST request is sent to /api/sessions/:sessionId/exercises with a name field, THE API SHALL create a new exercise linked to the specified session and return it with a 201 status code
2. WHEN a GET request is sent to /api/sessions/:sessionId/exercises, THE API SHALL return a JSON array of all exercises for the specified session with their associated workout sets
3. WHEN a PUT request is sent to /api/exercises/:id with a name field, THE API SHALL update the exercise name and return the updated exercise
4. WHEN a DELETE request is sent to /api/exercises/:id, THE API SHALL delete the exercise and all associated workout sets (cascade delete) and return a 200 status code
5. IF a POST request to create an exercise references a session id that does not exist, THEN THE API SHALL return a 404 status code with an error message
6. IF a POST request to create an exercise is missing the name field, THEN THE API SHALL return a 400 status code with a validation error message

### Requirement 5: Workout Set API Endpoints

**User Story:** As a user, I want to create, read, update, and delete sets within an exercise, so that I can track my reps and weight for each exercise.

#### Acceptance Criteria

1. WHEN a POST request is sent to /api/exercises/:exerciseId/sets with reps and weight fields, THE API SHALL create a new workout set linked to the specified exercise and return it with a 201 status code
2. WHEN a GET request is sent to /api/exercises/:exerciseId/sets, THE API SHALL return a JSON array of all workout sets for the specified exercise
3. WHEN a PUT request is sent to /api/sets/:id with reps and weight fields, THE API SHALL update the workout set and return the updated record
4. WHEN a DELETE request is sent to /api/sets/:id, THE API SHALL delete the workout set and return a 200 status code
5. IF a POST request to create a workout set references an exercise id that does not exist, THEN THE API SHALL return a 404 status code with an error message
6. IF a POST request to create a workout set is missing the reps or weight field, THEN THE API SHALL return a 400 status code with a validation error message

### Requirement 6: Flutter App API Integration

**User Story:** As a user, I want the Flutter app to persist my workout data to the online backend, so that my data is saved and accessible across app restarts.

#### Acceptance Criteria

1. THE Flutter_App SHALL use the dart http package to communicate with the Backend
2. WHEN a user starts a new session, THE API_Service SHALL send a POST request to create a session on the Backend
3. WHEN a user adds an exercise, THE API_Service SHALL send a POST request to create the exercise on the Backend
4. WHEN a user adds a set to an exercise, THE API_Service SHALL send a POST request to create the workout set on the Backend
5. WHEN a user removes an exercise, THE API_Service SHALL send a DELETE request to remove the exercise from the Backend
6. WHEN a user ends a session, THE API_Service SHALL send a PUT request to update the session end time on the Backend
7. IF the Backend is unreachable, THEN THE Flutter_App SHALL display an error message to the user

### Requirement 7: Workout History Screen

**User Story:** As a user, I want to view my past workout sessions on a separate screen, so that I can track my progress over time.

#### Acceptance Criteria

1. THE Flutter_App SHALL provide a History_Screen accessible via navigation from the main screen
2. WHEN the History_Screen is opened, THE API_Service SHALL fetch all sessions from the Backend and display them in a list
3. THE History_Screen SHALL display each session with its date and the number of exercises performed
4. WHEN a user taps on a session in the History_Screen, THE Flutter_App SHALL display the session details including all exercises and their sets
5. WHEN a user deletes a session from the History_Screen, THE API_Service SHALL send a DELETE request to the Backend and remove the session from the displayed list
6. IF no past sessions exist, THEN THE History_Screen SHALL display an empty state message indicating no workout history is available

### Requirement 8: Data Model Updates

**User Story:** As a developer, I want the Flutter data models to support JSON serialization and database identifiers, so that data can be exchanged with the REST API.

#### Acceptance Criteria

1. THE Flutter_App SHALL update the Session model to include an id field, a started_at field, and a nullable ended_at field
2. THE Flutter_App SHALL update the Exercise model to include an id field and a session_id field
3. THE Flutter_App SHALL update the WorkoutSet model to include an id field and an exercise_id field
4. THE Flutter_App SHALL implement fromJson and toJson methods on all model classes for JSON serialization
5. FOR ALL valid model objects, converting to JSON then parsing back from JSON SHALL produce an equivalent object (round-trip property)
