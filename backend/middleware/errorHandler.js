/**
 * Global error handler middleware.
 * Catches unhandled errors, logs them, and returns a 500 JSON response.
 */
function errorHandler(err, req, res, next) {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
}

module.exports = errorHandler;
