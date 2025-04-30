const mongoose = require('mongoose');

const AvoirVenteSchema = new mongoose.Schema({
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
  date_avoir: { 
    type: Date, 
    default: Date.now 
  },
  montant_avoir: { 
    type: Number, 
    default: 0.0 
  },
  statut: { 
    type: String, 
    enum: ['En attente', 'Traitée', 'Annulée'], 
    default: 'En attente' 
  }
});

// Empêcher de redéfinir le modèle
module.exports = mongoose.models.AvoirVente || mongoose.model('AvoirVente', AvoirVenteSchema);
