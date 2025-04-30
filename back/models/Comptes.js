const mongoose = require('mongoose');

// Schéma pour le modèle Compte
const CompteSchema = new mongoose.Schema({
  nom_compte: {
    type: String,
    required: true,
    trim: true // Enlever les espaces avant et après le nom
  },
  type_compte: {
    type: String,
    enum: ['Banque', 'Caisse', 'Autre'],
    required: true // Un compte doit avoir un type
  },
  solde: {
    type: Number,
    default: 0.00, // Valeur par défaut à 0 si non fourni
    min: [0, 'Le solde ne peut pas être négatif'] // Validation du solde positif
  },
  date_creation: {
    type: Date,
    default: Date.now // Date actuelle comme valeur par défaut
  },
  numero_compte: {
    type: String,
    unique: true, // Garantir que chaque compte ait un numéro unique
    sparse: true // Permettre à ce champ d'être nul, mais s'il est renseigné, il doit être unique
  },
  banque: {
    type: String,
    default: null // Champ optionnel
  },
  devise: {
    type: String,
    default: 'TND',
    enum: ['TND', 'USD', 'EUR', 'GBP'], // Liste des devises possibles
    required: true
  }
});

// Création du modèle basé sur le schéma
module.exports = mongoose.model('Compte', CompteSchema);
