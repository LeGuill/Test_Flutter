const bcrypt = require('bcrypt');
const db = require('../config/db'); // Pool de connexion MySQL

const register = async (req, res, next) => {
  const {
    userType,    // 'merchant' ou 'agent'
    firstName,
    companyLocation,
    email, 
    industry,
    phoneNumber,
    password,
    // confirmPassword,
    acceptedPrivacyPolicy // true ou false (on attendra true)
  } = req.body;
  const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS || '10'); // Nombre de tours pour bcrypt

  // --- Validation Côté Serveur ---
  if (!userType || !firstName || !email || !password || !acceptedPrivacyPolicy || !companyLocation || !industry) {

    return res.status(400).json({ message: 'Missing required fields (user type, first name, email, password, privacy policy acceptance)' });
  }

  // if (password !== confirmPassword) {
  //  return res.status(400).json({ message: 'Passwords do not match' });
  //}

  // Validation du type d'utilisateur
  if (userType !== 'merchant' && userType !== 'agent') {
      return res.status(400).json({ message: 'Invalid user type' });
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

      // Validation de la politique de confidentialité
      if (acceptedPrivacyPolicy !== true) { // Doit être explicitement true
        return res.status(400).json({ message: 'You must accept the privacy policy' });
    }

  try {
    // 1. Vérifier si l'email existe déjà
    const [existingUsers] = await db.query('SELECT email FROM users WHERE email = ?', [email]);

    if (existingUsers.length > 0) {
      return res.status(409).json({ message: 'Email already used' }); // 409 Conflict
    }

    // 2. Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(password, saltRounds);

// 3. Insérer le nouvel utilisateur dans la base de données (modifié)
const [result] = await db.query(
  `INSERT INTO users (
      user_type, first_name, company_location, email, industry, phone_number, password_hash, accepted_privacy_policy
   ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
  [
    userType,             // Correspond à user_type
    firstName,            // Correspond à first_name
    companyLocation,      // Correspond à company_location
    email,                // Correspond à email (colonne BDD)
    industry,             // Correspond à industry
    phoneNumber,          // Correspond à phone_number
    hashedPassword,       // Correspond à password_hash
    acceptedPrivacyPolicy // Correspond à accepted_privacy_policy
  ]
);

console.log('User registered:', { id: result.insertId, email: email }); // Log avec businessEmail


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