const mongoose = require('mongoose');

const DocumentSchema = new mongoose.Schema({
  titre: {
    type: String,
    required: true
  },
  type_document: {
    type: String,
    enum: ['Facture', 'Devis', 'Bon de commande', 'Bon de livraison', 'Rapport financier', 'Document technique'],
    required: true
  },
  chemin_fichier: {
    type: String,
    required: true
  },
  date_creation: {
    type: Date,
    default: Date.now
  },
  id_utilisateur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Utilisateur',
    default: null
  },
  id_entite: {
    type: mongoose.Schema.Types.ObjectId,
    refPath: 'type_entite',
    default: null
  },
  type_entite: {
    type: String,
    enum: ['Client', 'Fournisseur', 'Article', 'Vente', 'Achat'],
    default: null
  },
  description: {
    type: String,
    default: null
  }
});

module.exports = mongoose.model('Document', DocumentSchema);
