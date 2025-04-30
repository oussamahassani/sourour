// models/bonTransfert.js
const mongoose = require('mongoose');

const bonTransfertSchema = new mongoose.Schema({
  id_entrepot_source: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Entrepot',
    default: null
  },
  id_entrepot_destination: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Entrepot',
    default: null
  },
  date_transfert: {
    type: Date,
    default: Date.now
  },
  statut: {
    type: String,
    enum: ['En attente', 'Terminé', 'Annulé'],
    default: 'En attente'
  }
});

module.exports = mongoose.model('BonTransfert', bonTransfertSchema);
