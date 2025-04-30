// models/bonsRetours.js
const mongoose = require('mongoose');

const BonsRetourSchema = new mongoose.Schema({
  id_vente: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Vente', 
    default: null 
  },
  id_client: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Client', 
    default: null 
  },
  date_retour: { 
    type: Date, 
    default: Date.now 
  },
  montant_total: { 
    type: Number, 
    default: 0.0 
  },
  statut: { 
    type: String, 
    enum: ['En attente', 'Traitée', 'Annulée'], 
    default: 'En attente' 
  }
});

module.exports = mongoose.model('BonsRetour', BonsRetourSchema);
