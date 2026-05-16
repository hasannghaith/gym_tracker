/**
 * Property-based tests for Exercise API routes
 * 
 * Feature: gym-tracker-backend
 * Validates: Requirements 4.1, 4.5, 4.6
 */

const request = require('supertest');
const fc = require('fast-check');

// Mock the database pool before requiring the app
jest.mock('../db');
const pool = require('../db');
const app = require('../index');

describe('Exercise Routes - Property Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  /**
   * Property 4: Create Operations Return Correct Resource
   * POST /api/sessions/:sessionId/exercises returns 201 with id, session_id, and name
   */
  describe('Property 4: Create Operations Return Correct Resource', () => {
    it('POST exercises returns 201 with id, session_id, and name for any valid exercise name', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 10000 }),
          fc.string({ minLength: 1, maxLength: 100 }).filter(s => s.trim().length > 0),
          async (sessionId, exerciseName) => {
            const insertId = Math.floor(Math.random() * 10000) + 1;

            // Mock: session exists
            pool.execute.mockImplementation((query) => {
              if (query.includes('SELECT id FROM sessions')) {
                return Promise.resolve([[{ id: sessionId }]]);
              }
              if (query.includes('INSERT INTO exercises')) {
                return Promise.resolve([{ insertId }]);
              }
              return Promise.resolve([[]]);
            });

            const res = await request(app)
              .post(`/api/sessions/${sessionId}/exercises`)
              .send({ name: exerciseName });

            // Status must be 201
            expect(res.status).toBe(201);

            // Response must contain id, session_id, and name
            expect(res.body).toHaveProperty('id', insertId);
            expect(res.body).toHaveProperty('session_id', sessionId);
            expect(res.body).toHaveProperty('name', exerciseName);
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  /**
   * Property 10: Missing Required Fields Return 400
   * POST without name returns 400
   */
  describe('Property 10: Missing Required Fields Return 400', () => {
    it('POST exercises without name field returns 400 for any session id', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 10000 }),
          async (sessionId) => {
            // No mock needed for session lookup since validation happens first
            const res = await request(app)
              .post(`/api/sessions/${sessionId}/exercises`)
              .send({});

            expect(res.status).toBe(400);
            expect(res.body).toHaveProperty('error');
          }
        ),
        { numRuns: 100 }
      );
    });

    it('POST exercises with empty string name returns 400 for any session id', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 10000 }),
          fc.constantFrom('', '   ', '\t', '\n'),
          async (sessionId, emptyName) => {
            const res = await request(app)
              .post(`/api/sessions/${sessionId}/exercises`)
              .send({ name: emptyName });

            expect(res.status).toBe(400);
            expect(res.body).toHaveProperty('error');
          }
        ),
        { numRuns: 100 }
      );
    });

    it('POST exercises with null name returns 400', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 10000 }),
          async (sessionId) => {
            const res = await request(app)
              .post(`/api/sessions/${sessionId}/exercises`)
              .send({ name: null });

            expect(res.status).toBe(400);
            expect(res.body).toHaveProperty('error');
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  /**
   * Property 9: Non-Existent Resource References Return 404
   * POST to non-existent session returns 404
   */
  describe('Property 9: Non-Existent Resource References Return 404', () => {
    it('POST exercises to non-existent session returns 404 for any valid name', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.integer({ min: 1, max: 10000 }),
          fc.string({ minLength: 1, maxLength: 100 }).filter(s => s.trim().length > 0),
          async (sessionId, exerciseName) => {
            // Mock: session does NOT exist
            pool.execute.mockImplementation((query) => {
              if (query.includes('SELECT id FROM sessions')) {
                return Promise.resolve([[]]);
              }
              return Promise.resolve([[]]);
            });

            const res = await request(app)
              .post(`/api/sessions/${sessionId}/exercises`)
              .send({ name: exerciseName });

            expect(res.status).toBe(404);
            expect(res.body).toHaveProperty('error');
          }
        ),
        { numRuns: 100 }
      );
    });
  });
});
