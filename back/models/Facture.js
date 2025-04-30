const mongoose = require('mongoose');

const FactureSchema = new mongoose.Schema({
  numero_facture: {
    type: String,
    required: true,
    unique: true
  },
  idACH: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Achat',
    default: null
  },
  idV: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vente',
    default: null
  },
  idF: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Fournisseur',
    default: null
  },
  idP: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Produit',
    default: null
  },
  idCL: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Client',
    default: null
  },
  idU: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Utilisateur',
    default: null
  },
  date_creation: {
    type: Date,
    default: Date.now
  },
  prixHTV: {
    type: Number,
    required: true
  },
  TVA: {
    type: Number,
    required: true
  },
  prixTTC: {
    type: Number,
    required: true
  },
  type: {
    type: String,
    enum: ['Achat', 'Vente'],
    required: true
  },
  date_echeance: {
    type: Date,
    default: null
  },
  statut: {
    type: String,
    enum: ['Brouillon', 'Émise', 'Payée', 'Annulée', 'En retard'],
    default: 'Brouillon'
  },
  id_document: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Document',
    default: null
  }
});

module.exports = mongoose.model('Facture', FactureSchema);
