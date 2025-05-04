const bcrypt = require('bcrypt');
const db = require('../config/db'); // Assurez-vous que ce chemin est correct et exporte le pool/connexion DB

const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS || '10'); // Nombre de tours pour bcrypt

// --- Fonction Register (Existante - légèrement reformatée pour lisibilité) ---
const register = async (req, res, next) => {
  const {
    userType, firstName, companyLocation, email, industry, phoneNumber, password, acceptedPrivacyPolicy
  } = req.body;

  // --- Validation Côté Serveur ---
  if (!userType || !firstName || !email || !password || acceptedPrivacyPolicy !== true || !companyLocation || !industry) {
    // J'ai mis acceptedPrivacyPolicy ici car il doit être true
    return res.status(400).json({ message: 'Missing or invalid required fields (user type, first name, email, password, company location, industry, privacy policy acceptance)' });
  }
  if (userType !== 'merchant' && userType !== 'agent') {
      return res.status(400).json({ message: 'Invalid user type' });
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
      return res.status(400).json({ message: 'Invalid email format' });
  }
  if (password.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters long' });
  }

  try {
    // 1. Vérifier si l'email existe déjà
    const [existingUsers] = await db.query('SELECT email FROM users WHERE email = ?', [email]);
    if (existingUsers.length > 0) {
      return res.status(409).json({ message: 'Email already used' });
    }

    // 2. Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // 3. Insérer le nouvel utilisateur
    const [result] = await db.query(
      `INSERT INTO users (user_type, first_name, company_location, email, industry, phone_number, password_hash, accepted_privacy_policy) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [userType, firstName, companyLocation, email, industry, phoneNumber, hashedPassword, acceptedPrivacyPolicy]
    );

    console.log('User registered:', { id: result.insertId, email: email });

    // 4. Envoyer une réponse de succès
    res.status(201).json({
       message: 'User registered successfully',
       userId: result.insertId
    });

  } catch (error) {
    console.error("Registration error:", error);
    next(error); // Passe à la gestion d'erreur globale
  }
};


// --- <<< AJOUT : Nouvelle Fonction Login >>> ---
const login = async (req, res, next) => {
  const { email, password } = req.body; // Récupère email/mdp envoyés par Flutter

  // 1. Validation simple des entrées
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    // 2. Chercher l'utilisateur par email
    // Sélectionne aussi les champs nécessaires pour la réponse (sauf le hash)
    const [users] = await db.query(
      'SELECT id, email, password_hash, first_name, user_type FROM users WHERE email = ?',
      [email]
    );

    // 3. Vérifier si l'utilisateur existe
    if (users.length === 0) {
      console.log(`Login attempt failed: Email not found - ${email}`);
      return res.status(401).json({ message: 'Invalid email or password' }); // Non autorisé
    }

    const user = users[0]; // L'utilisateur trouvé

    // 4. Comparer le mot de passe fourni avec le hash stocké
    const isPasswordMatch = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordMatch) {
      console.log(`Login attempt failed: Incorrect password for email - ${email}`);
      return res.status(401).json({ message: 'Invalid email or password' }); // Non autorisé
    }

    // 5. Connexion réussie !
    console.log('User logged in:', { id: user.id, email: user.email });

    // TODO: Pour une vraie application, générer et renvoyer un Token JWT ici.
    // Le token contiendrait des informations comme userId, userType, etc.
    // et serait utilisé par le frontend pour les requêtes authentifiées.

    // Pour ce test, on renvoie juste un succès et quelques infos (SANS LE HASH !)
    res.status(200).json({ // 200 OK
      message: 'Login successful',
      // Renvoyer les données utiles pour le frontend après connexion
      userData: {
        userId: user.id,
        firstName: user.first_name,
        email: user.email,
        userType: user.user_type
        // Ajoutez d'autres champs si nécessaire, mais JAMAIS le hash du mot de passe
      }
      // jwtToken: generatedToken // Si vous implémentez JWT
    });

  } catch (error) {
    console.error("Login error:", error);
    next(error); // Passe à la gestion d'erreur globale
  }
};


// <<< MODIFIÉ : Exporter les deux fonctions >>>
module.exports = {
  register,
  login, // Ajouter la fonction login à l'export
};
