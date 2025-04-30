// models/bonLivraisonAchat.js
const mongoose = require('mongoose');

const BonLivraisonAchatSchema = new mongoose.Schema({
  id_achat: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Achat', 
    default: null 
  },
  id_fournisseur: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Fournisseur', 
    default: null 
  },
  date_livraison: { 
    type: Date, 
    default: Date.now 
  },
  statut: { 
    type: String, 
    enum: ['En attente', 'Livré', 'Annulé'], 
    default: 'En attente' 
  }
});

module.exports = mongoose.model('BonLivraisonAchat', BonLivraisonAchatSchema);
