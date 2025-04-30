const mongoose = require('mongoose');

const EncaissementSchema = new mongoose.Schema({
  id_facture: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Facture',
    default: null
  },
  id_client: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Client',
    default: null
  },
  montant: {
    type: Number,
    required: true
  },
  mode_paiement: {
    type: String,
    enum: ['Espèces', 'Carte bancaire', 'Chèque', 'Virement', 'Autre'],
    default: 'Espèces'
  },
  date_encaissement: {
    type: Date,
    default: Date.now
  },
  utilisateur_encaissement: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Utilisateur',
    default: null
  },
  commentaire: {
    type: String,
    default: null
  }
});

module.exports = mongoose.model('Encaissement', EncaissementSchema);
