const mongoose = require('mongoose');

const BonCventeSchema = new mongoose.Schema({
  reference: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  client: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Client',
    required: true
  },
  date: {
    type: Date,
    default: Date.now
  },
  adresseLivraison: {
    type: String,
    required: true,
    trim: true
  },
  delaiLivraison: {
    type: Number,
    default: 15,
    min: 1
  },
  conditionsPaiement: {
    type: String,
    default: '30 jours fin de mois'
  },
  remise: {
    type: Number,
    default: 0,
    min: 0
  },
  articles: [{
    article: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Article'
    },
    nom: String,
    description: String,
    quantite: {
      type: Number,
      required: true,
      min: 1
    },
    prixHT: {
      type: Number,
      required: true,
      min: 0
    },
    tva: {
      type: Number,
      default: 20.0,
      min: 0
    }
  }],
  sousTotalHT: {
    type: Number,
    default: 0,
    min: 0
  },
  totalTVA: {
    type: Number,
    default: 0,
    min: 0
  },
  totalHT: {
    type: Number,
    default: 0,
    min: 0
  },
  totalCommande: {
    type: Number,
    default: 0,
    min: 0
  },
  methode: {
    type: String,
    enum: ['complete', 'rapide'],
    required: true
  },
  imagePath: {
    type: String
  },
  statut: {
    type: String,
    enum: ['en_attente', 'valide', 'livre', 'annule'],
    default: 'en_attente'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Middleware pour calculer les totaux avant sauvegarde
BonCventeSchema.pre('save', function(next) {  // Changé de bonCommandeSchema à BonCventeSchema
  this.sousTotalHT = this.articles.reduce((sum, article) => sum + (article.prixHT * article.quantite), 0);
  this.totalTVA = this.articles.reduce((sum, article) => sum + (article.prixHT * article.quantite * (article.tva / 100)), 0);
  this.totalHT = this.sousTotalHT - this.remise;
  this.totalCommande = this.totalHT + this.totalTVA;
  next();
});

module.exports = mongoose.model('BonCvente', BonCventeSchema);  // Changé de bonCventeSchema à BonCventeSchema
