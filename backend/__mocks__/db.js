/**
 * Manual mock for the database pool module.
 * Provides a mock execute function that tests can configure.
 */
const pool = {
  execute: jest.fn()
};

module.exports = pool;
