const mongoose = require('mongoose');

const BonLivraisonSchema = new mongoose.Schema({
  reference: {
    type: String,
    unique: true
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
  adresseLivraison: String,
  articles: [{
    article: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Article',
      required: true
    },
    quantiteLivree: {
      type: Number,
      required: true,
      min: 1
    },
    prixHT: Number
  }],
  totalHT: Number,
  statut: {
    type: String,
    default: 'Préparé',
    enum: ['Préparé', 'Livré', 'Annulé']
  }
}, { timestamps: true });

// Génération automatique de la référence
BonLivraisonSchema.pre('save', async function(next) {
  if (!this.reference) {
    const count = await mongoose.models.BonLivraison.countDocuments();
    this.reference = `BL-${(count + 1).toString().padStart(4, '0')}`;
  }
  next();
});

// Calcul du total HT avant sauvegarde
BonLivraisonSchema.pre('save', function(next) {
  if (this.articles && this.articles.length > 0) {
    this.totalHT = this.articles.reduce((total, item) => {
      return total + (item.quantiteLivree * (item.prixHT || 0));
    }, 0);
  }
  next();
});

module.exports = mongoose.model('BonLivraison', BonLivraisonSchema);
