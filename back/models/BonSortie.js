// models/bonSortie.js
const mongoose = require('mongoose');

const bonSortieSchema = new mongoose.Schema({
  numero_BS: {
    type: String,
    unique: true,
    required: true
  },
  id_utilisateur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Utilisateur',
    default: null
  },
  date_sortie: {
    type: Date,
    default: Date.now
  },
  motif: {
    type: String,
    enum: ['Vente', 'Retour', 'Perte', 'Autre'],
    default: 'Vente'
  },
  commentaire: {
    type: String,
    default: ''
  }
});

module.exports = mongoose.model('BonSortie', bonSortieSchema);
