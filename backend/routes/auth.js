const express = require('express');
// Crée un routeur pour regrouper les routes liées à l'authentification.
const router = express.Router();
// Importe les fonctions de logique (register, login).
const authController = require('../controllers/authController');

// Route pour gérer l'inscription des utilisateurs (appelle la fonction register).
router.post('/register', authController.register);

// Route pour gérer la connexion des utilisateurs (appelle la fonction login).
router.post('/login', authController.login);

// Rend ce routeur disponible pour être utilisé dans l'application principale.
module.exports = router;