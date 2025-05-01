const bcrypt = require('bcrypt');
const db = require('../config/db'); // Pool de connexion MySQL

const register = async (req, res, next) => {
  const { firstName, lastName, email, password, confirmPassword } = req.body;
  const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS || '10'); // Nombre de tours pour bcrypt

  // --- Validation Côté Serveur ---
  if (!firstName || !lastName || !email || !password || !confirmPassword) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  if (password !== confirmPassword) {
    return res.status(400).json({ message: 'Passwords do not match' });
  }

  // Validation simple de l'email (peut être améliorée avec une regex plus robuste ou une librairie)
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
      return res.status(400).json({ message: 'Invalid email format' });
  }

  // Validation simple de la complexité du mot de passe (ex: min 6 caractères)
  if (password.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters long' });
  }

  try {
    // 1. Vérifier si l'email existe déjà
    const [existingUsers] = await db.query('SELECT email FROM users WHERE email = ?', [email]);

    if (existingUsers.length > 0) {
      return res.status(409).json({ message: 'Email already exists' }); // 409 Conflict
    }

    // 2. Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // 3. Insérer le nouvel utilisateur dans la base de données
    const [result] = await db.query(
      'INSERT INTO users (first_name, last_name, email, password_hash) VALUES (?, ?, ?, ?)',
      [firstName, lastName, email, hashedPassword]
    );

    console.log('User registered:', { id: result.insertId, email: email });

    // 4. Envoyer une réponse de succès
    
    res.status(201).json({
       message: 'User registered successfully',
       userId: result.insertId 
    });

  } catch (error) {
    console.error("Registration error:", error);
    // Passer l'erreur au gestionnaire global d'erreurs défini dans server.js
    next(error); // Envoie une réponse 500 par défaut
  }
};

module.exports = {
  register,
};