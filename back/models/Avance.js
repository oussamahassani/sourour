const mongoose = require('mongoose');

const AvanceSchema = new mongoose.Schema({
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
    default: 0.0 
  },
  date_avance: { 
    type: Date, 
    default: Date.now 
  },
  mode_paiement: { 
    type: String, 
    enum: ['Espèces', 'Carte bancaire', 'Chèque', 'Virement', 'Autre'], 
    default: 'Espèces' 
  },
  commentaire: { 
    type: String, 
    default: '' 
  }
});

module.exports = mongoose.model('Avance', AvanceSchema);
