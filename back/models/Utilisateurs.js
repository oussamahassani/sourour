const mongoose = require('mongoose');

// Définir le schéma utilisateur
const userSchema = new mongoose.Schema({
  nom: { type: String, required: true },
  prenom: { type: String, required: true },
  telephone: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  motDePasse: { type: String, required: true },
  role: { type: String, enum: ['Utilisateur', 'Admin'], default: 'Utilisateur' },
});

// Créer et exporter le modèle
const Utilisateurs = mongoose.model('Utilisateurs', userSchema);  // Assurez-vous que le nom ici est "Utilisateurs"
module.exports = Utilisateurs;  // L'exportation est maintenant cohérente
