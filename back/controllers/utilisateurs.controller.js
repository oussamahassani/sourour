const User = require('../models/Utilisateurs');

// Fonction d'inscription
const signup = async (req, res) => {
  const { nom, prenom, telephone, email, motDePasse, role } = req.body;

  // Vérification des champs
  if (!nom || !prenom || !telephone || !email || !motDePasse || !role) {
    return res.status(400).json({ message: 'Tous les champs sont requis.' });
  }

  try {
    // Vérification si l'utilisateur existe déjà
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Un utilisateur avec cet email existe déjà.' });
    }

    // Création de l'utilisateur
    const newUser = new User({ nom, prenom, telephone, email, motDePasse, role });
    // Vous pouvez ici hasher le mot de passe si nécessaire
    await newUser.save();

    res.status(201).json({ message: 'Utilisateur créé avec succès.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur, veuillez réessayer.' });
  }
};

module.exports = { signup };
