const mongoose = require('mongoose');
const { fillAndStroke } = require('pdfkit');

const itemSchema = new mongoose.Schema({
  article: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Article',
    required: true
  },
  quantite: {
    type: Number,
    required: true,
    min: 1
  }
});

const bonSortieSchema = new mongoose.Schema({
  numero: {
    type: String,
    unique: true,
    required: false
  },
  responsable: {
    type: String,
    required: true
  },
  service: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  typeMateriel: {
    type: String,
    required: true
  },
  dateSortie: {
    type: Date,
    default: Date.now,
    required: true
  },
  client: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Client',
    required: true
  },
  items: [itemSchema],
  statut: {
    type: String,
    enum: ['enregistré', 'validé', 'annulé'],
    default: 'enregistré'
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Generate bon de sortie number before saving
bonSortieSchema.pre('save', async function(next) {
  if (!this.numero) {
    const count = await mongoose.models.BonSortie.countDocuments();
    this.numero = `BS-${(count + 1).toString().padStart(4, '0')}`;
  }
  next();
});

// Update article stock when bon de sortie is validated
bonSortieSchema.post('save', async function(doc, next) {
  if (doc.statut === 'validé') {
    const Article = mongoose.model('Article');
    
    for (const item of doc.items) {
      await Article.findByIdAndUpdate(
        item.article,
        { $inc: { stock: -item.quantite } }
      );
    }
  }
  next();
});

module.exports = mongoose.model('BonSortie', bonSortieSchema);
