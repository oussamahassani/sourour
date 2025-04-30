// models/bonLivraisonVente.js
const mongoose = require('mongoose');

const BonLivraisonVenteSchema = new mongoose.Schema({
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

module.exports = mongoose.model('BonLivraisonVente', BonLivraisonVenteSchema);
