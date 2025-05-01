require('dotenv').config(); // Charger .env au tout début
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');

const app = express();

// Middleware
app.use(cors()); // Activer CORS pour toutes les origines
app.use(express.json()); // Pour parser le JSON des requêtes entrantes
app.use(express.urlencoded({ extended: true })); // Pour parser les données de formulaire URL-encoded

// Routes
app.get('/', (req, res) => {
  res.send('API Reno Energie - Backend is running!');
});
app.use('/api/auth', authRoutes); // Préfixer les routes d'authentification

// Gestion basique des erreurs 404
app.use((req, res, next) => {
  res.status(404).json({ message: 'Resource not found' });
});

// Gestion globale des erreurs (doit être le dernier middleware)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    message: err.message || 'Something went wrong!',
    // error: process.env.NODE_ENV === 'development' ? err : {} // Ne pas exposer les détails en prod
  });
});


const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});