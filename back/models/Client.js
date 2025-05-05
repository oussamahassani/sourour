const mongoose = require('mongoose');

const ClientSchema = new mongoose.Schema({
  nom: {
    type: String,
    trim: true
  },
  prenom: {
    type: String,
    trim: true
  },
  email: {
    type: String,
    trim: true,
    unique: true,
    lowercase: true,
    match: [/.+\@.+\..+/, 'Veuillez entrer une adresse email valide']
  },
  telephone: {
    type: String,
    trim: true,
  },
  adresse: {
    type: String,
    trim: true
  },
  plafond_credit: {
    type: mongoose.Types.Decimal128,
    default: 0.00
  },
  validation_admin: {
    type: Boolean,
    default: false
  },
  date_creation: {
    type: Date,
    default: Date.now
  },
  entreprise: {
    type: String,
    trim: true
  },
  matricule: {
    type: String,
    trim: true
  },
  cin: {
    type: String,
    required: true
  },
  commercial_assigne: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User', // Assurez-vous que le modèle 'Utilisateur' existe
    default: null
  }
});

module.exports = mongoose.model('Client', ClientSchema);
