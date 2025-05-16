const mongoose = require('mongoose');

const articleDevisSchema = new mongoose.Schema({
  article: { type: mongoose.Schema.Types.ObjectId, ref: 'Article', required: true },
  nom: { type: String, required: true },
  description: { type: String },
  quantite: { type: Number, required: true, min: 1 },
  prixHT: { type: Number, required: true, min: 0 },
  tva: { type: Number, required: true, min: 0, max: 100 },
  montantHT: { type: Number, required: true },
  montantTVA: { type: Number, required: true },
  montantTTC: { type: Number, required: true }
});

const devisSchema = new mongoose.Schema({
  reference: { type: String, unique: true, required: true },
  client: { type: mongoose.Schema.Types.ObjectId, ref: 'Client', required: true },
  dateCreation: { type: Date, default: Date.now },
  dateValidite: { type: Date, },
  adresseLivraison: { type: String,  },
  conditionsPaiement: { type: String, default: '30 jours fin de mois' },
  remise: { type: Number, default: 0, min: 0 },
  sousTotalHT: { type: Number, },
  totalTVA: { type: Number},
  totalHT: { type: Number },
  totalTTC: { type: Number},
  articles: [articleDevisSchema],
  methode: { type: String, required: true, enum: ['complete', 'rapide'], default: 'complete' },
  imageDevis: { type: String },
  statut: { type: String, enum: ['En attente', 'Accepté', 'Refusé', 'Annulé'], default: 'En attente' }
}, { timestamps: true });

module.exports = mongoose.model('Devis', devisSchema);
