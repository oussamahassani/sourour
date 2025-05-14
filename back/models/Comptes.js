const mongoose = require('mongoose');

const CompteSchema = new mongoose.Schema({
  nom_compte: {
    type: String,
    required: [true, 'Veuillez ajouter un nom pour le compte'],
    trim: true,
    maxlength: [50, 'Le nom ne peut pas dépasser 50 caractères']
  },
  type_compte: {
    type: String,
    required: [true, 'Veuillez spécifier le type de compte'],
    enum: ['Banque', 'Caisse', 'Portefeuille', 'Placement', 'Autre'],
    default: 'Banque'
  },
  numero_compte: {
    type: String,
    trim: true,
    maxlength: [30, 'Le numéro de compte ne peut pas dépasser 30 caractères']
  },
  banque: {
    type: String,
    trim: true,
    maxlength: [50, 'Le nom de la banque ne peut pas dépasser 50 caractères']
  },
  devise: {
    type: String,
    required: [true, 'Veuillez spécifier la devise'],
    default: 'TND',
    trim: true,
    maxlength: [5, 'La devise ne peut pas dépasser 5 caractères']
  },
  rib: {
    type: String,
    required: function() {
      return this.type_compte === 'Banque';
    },
    trim: true,
    maxlength: [24, 'Le RIB ne peut pas dépasser 24 caractères']
  },
  solde: {
    type: Number,
    required: [true, 'Veuillez spécifier le solde initial'],
    default: 0.0
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Validation conditionnelle pour les comptes bancaires
CompteSchema.pre('save', function(next) {
  if (this.type_compte === 'Banque' && !this.banque) {
    this.invalidate('banque', 'Veuillez spécifier la banque pour un compte bancaire');
  }
  next();
});

module.exports = mongoose.model('Compte', CompteSchema);
