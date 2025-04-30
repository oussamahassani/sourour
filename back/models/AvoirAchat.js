const mongoose = require('mongoose');

const AvoirAchatSchema = new mongoose.Schema({
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
module.exports = mongoose.models.AvoirAchat || mongoose.model('AvoirAchat', AvoirAchatSchema);
