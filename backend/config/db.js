const mysql = require('mysql2/promise'); // Utilise la version promise
require('dotenv').config(); // Charge les variables de .env

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Teste la connexion à la base de données
pool.getConnection()
  .then(connection => {
    console.log('MySQL Connected...');
    connection.release(); // Libère la connexion
  })
  .catch(err => {
    console.error('Error connecting to MySQL:', err.stack);
  });

module.exports = pool;