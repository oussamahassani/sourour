const mongoose = require('mongoose');

const ArticleSchema = new mongoose.Schema({
  // Nom de l'article
  article: { 
    type: String, 
    required: true, 
    trim: true 
  },
  reference:{
    type: String, 

  },
  // Description de l'article
  description: { 
    type: String, 
    trim: true 
  },

  // Prix d'achat
  prix_achat: { 
    type: Number, 
    required: true 
  },

  // Prix de vente
  prix_vente: { 
    type: Number 
  },

  // Taux de marge
  taux_marge: { 
    type: Number, 
    required: true 
  },

  // Stock actuel
  stock: { 
    type: Number, 
    default: 0 
  },

  // Seuil d'alerte pour le stock
  alerte_stock: { 
    type: Number, 
    default: 5 
  },

  // Date de création
  date_creation: { 
    type: Date, 
    default: Date.now 
  },

  // Catégorie de l'article
  categorie: { 
    type: String, 
    enum: ['Climatiseur','Sanitaire', 'Chauffage', 'Fourniture', 'Pièce détachée'], 
    required: true 
  }
});

// Exporter le modèle pour l'utilisation dans d'autres fichiers
module.exports = mongoose.model('Article', ArticleSchema);
