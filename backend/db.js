require('dotenv').config();
const mysql = require('mysql2');

console.log('[DB] Connecting with config:', {
  host: process.env.DB_HOST || '(NOT SET)',
  port: process.env.DB_PORT || '3306 (default)',
  user: process.env.DB_USER || '(NOT SET)',
  database: process.env.DB_NAME || '(NOT SET)',
  password: process.env.DB_PASSWORD ? '***set***' : '(NOT SET)'
});

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool.promise();
