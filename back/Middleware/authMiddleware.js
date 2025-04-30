const jwt = require('jsonwebtoken');

exports.authenticate = (req, res, next) => {
  // Extraire le token de l'en-tête Authorization
  const token = req.header('Authorization')?.replace('Bearer ', '');

  // Vérifier si le token est présent
  if (!token) {
    return res.status(401).json({ message: 'Accès refusé. Token manquant.' });
  }

  try {
    // Vérification et décodage du token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('Decoded Token:', decoded);  // Log du token décodé pour déboguer

    // Vérification du rôle de l'utilisateur (si nécessaire)
    if (!decoded.role) {
      return res.status(403).json({ message: 'Accès interdit. Rôle manquant dans le token.' });
    }

    if (decoded.role !== 'user') {
      return res.status(403).json({ message: 'Accès interdit. Rôle insuffisant.' });
    }

    // Ajouter les informations de l'utilisateur (décodées) à la requête
    req.user = decoded;

    // Passer au middleware suivant ou à la route
    next();
  } catch (err) {
    console.error('Erreur lors de la vérification du token:', err);  // Log de l'erreur

    // Gestion de l'erreur : Token expiré ou autre erreur
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expiré. Veuillez vous réauthentifier.' });
    }

    // Pour toutes autres erreurs liées au token
    return res.status(401).json({ message: 'Token invalide.' });
  }
};
