const bcrypt = require('bcrypt'); // Pour hacher les mots de passe de manière sécurisée
const db = require('../config/db'); // Module pour interagir avec la base de données

// Configuration pour la robustesse du hachage de mot de passe. Plus c'est élevé, plus c'est sûr mais lent.
const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS || '10');

// --- Fonction Register ---
// Crée un nouvel utilisateur. 'async' permet d'attendre les opérations BDD.
const register = async (req, res, next) => {
  // Récupère les données du formulaire d'inscription envoyées par le client (ex: Flutter)
  const {
    userType, firstName, companyLocation, email, industry, phoneNumber, password, acceptedPrivacyPolicy
  } = req.body;

  // --- Validation Côté Serveur ---
  // Essentiel pour la sécurité et l'intégrité des données, même si l'app client valide déjà.
  if (!userType || !firstName || !email || !password || acceptedPrivacyPolicy !== true || !companyLocation || !industry) {
    return res.status(400).json({ message: 'Missing or invalid required fields (...)' }); // 400: Requête client incorrecte
  }
  if (userType !== 'merchant' && userType !== 'agent') {
    return res.status(400).json({ message: 'Invalid user type' });
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/; // Format email simple
  if (!emailRegex.test(email)) {
    return res.status(400).json({ message: 'Invalid email format' });
  }
  if (password.length < 6) { // Minimum de sécurité pour le mot de passe
    return res.status(400).json({ message: 'Password must be at least 6 characters long' });
  }

  // 'try...catch' pour gérer les erreurs inattendues (ex: BDD indisponible)
  try {
    // 1. Vérifier si l'email existe déjà pour éviter les doublons
    // L'utilisation de '?' protège contre les injections SQL (faille de sécurité majeure)
    const [existingUsers] = await db.query('SELECT email FROM users WHERE email = ?', [email]);
    if (existingUsers.length > 0) {
      return res.status(409).json({ message: 'Email already used' }); // 409: Conflit, l'email existe déjà
    }

    // 2. Hasher le mot de passe avant stockage (ne JAMAIS stocker en clair)
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // 3. Insérer le nouvel utilisateur en BDD
    // Encore '?' pour la sécurité contre les injections SQL
    const [result] = await db.query(
      `INSERT INTO users (user_type, first_name, company_location, email, industry, phone_number, password_hash, accepted_privacy_policy) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [userType, firstName, companyLocation, email, industry, phoneNumber, hashedPassword, acceptedPrivacyPolicy]
    );

    console.log('User registered:', { id: result.insertId, email: email }); // Log serveur pour suivi

    // 4. Réponse de succès
    res.status(201).json({ // 201: Ressource créée avec succès
        message: 'User registered successfully',
        userId: result.insertId // L'ID du nouvel utilisateur peut être utile côté client
    });

  } catch (error) {
    console.error("Registration error:", error); // Log l'erreur pour le debug
    next(error); // Passe l'erreur au gestionnaire global pour une réponse serveur propre (souvent 500)
  }
};


// --- Fonction Login ---
// Vérifie les identifiants et connecte l'utilisateur.
const login = async (req, res, next) => {
  const { email, password } = req.body; // Récupère email/mdp envoyés par le client

  // 1. Validation simple des entrées
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    // 2. Chercher l'utilisateur par email en BDD
    // Sélectionne les champs nécessaires (y compris le hash pour comparaison)
    // Toujours utiliser '?' pour se protéger des injections SQL
    const [users] = await db.query(
      'SELECT id, email, password_hash, first_name, user_type FROM users WHERE email = ?',
      [email]
    );

    // 3. Vérifier si l'utilisateur existe
    const user = users[0]; // Prend le premier (et unique normalement) utilisateur trouvé
    if (!user) {
      // Sécurité: Message d'erreur générique pour ne pas révéler si l'email existe ou non.
      console.log(`Login attempt failed: Email not found - ${email}`); // Log serveur spécifique
      return res.status(401).json({ message: 'Invalid email or password' }); // 401: Non autorisé
    }

    // 4. Comparer le mot de passe fourni avec le hash stocké
    // bcrypt.compare fait la comparaison de manière sécurisée sans déchiffrer le hash.
    const isPasswordMatch = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordMatch) {
      // Sécurité: Même message d'erreur générique que pour l'email non trouvé.
      console.log(`Login attempt failed: Incorrect password for email - ${email}`); // Log serveur spécifique
      return res.status(401).json({ message: 'Invalid email or password' }); // 401: Non autorisé
    }

    // 5. Connexion réussie !
    console.log('User logged in:', { id: user.id, email: user.email });

    // Envoyer une réponse de succès avec quelques données utilisateur utiles pour l'app client.
    // Important: NE JAMAIS renvoyer le hash du mot de passe ('password_hash').
    res.status(200).json({ // 200: OK
      message: 'Login successful',
      userData: {
        userId: user.id,
        firstName: user.first_name,
        email: user.email,
        userType: user.user_type
        // Ici, on pourrait générer un token JWT pour gérer la session
      }
    });

  } catch (error) {
    console.error("Login error:", error);
    next(error); // Gestion centralisée des erreurs serveur
  }
};


// Exporte les fonctions pour les rendre utilisables par le système de routage (ex: Express router)
module.exports = {
  register,
  login,
};