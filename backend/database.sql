CREATE TABLE IF NOT EXISTS sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ended_at TIMESTAMP NULL
);

CREATE TABLE IF NOT EXISTS exercises (
  id INT AUTO_INCREMENT PRIMARY KEY,
  session_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS workout_sets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  exercise_id INT NOT NULL,
  reps INT NOT NULL,
  weight DECIMAL(6,2) NOT NULL,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);

INSERT INTO sessions (started_at, ended_at) VALUES
('2026-05-10 08:00:00', '2026-05-10 09:15:00'),
('2026-05-12 17:30:00', '2026-05-12 18:45:00'),
('2026-05-14 07:00:00', '2026-05-14 08:20:00');

INSERT INTO exercises (session_id, name) VALUES
(1, 'Bench Press'),
(1, 'Squat'),
(1, 'Deadlift'),
(2, 'Shoulder Press'),
(2, 'Bicep Curl'),
(3, 'Leg Press'),
(3, 'Lat Pulldown'),
(3, 'Tricep Dip');

INSERT INTO workout_sets (exercise_id, reps, weight) VALUES
(1, 10, 60.00),
(1, 8, 70.00),
(1, 6, 80.00),
(2, 12, 80.00),
(2, 10, 90.00),
(2, 8, 100.00),
(3, 5, 120.00),
(3, 5, 130.00),
(4, 10, 40.00),
(4, 8, 45.00),
(5, 12, 15.00),
(5, 10, 17.50),
(6, 12, 150.00),
(6, 10, 170.00),
(7, 10, 50.00),
(7, 8, 55.00),
(8, 12, 0.00),
(8, 10, 10.00);
