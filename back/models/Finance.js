const mongoose = require('mongoose');

const FinanceRecordSchema = new mongoose.Schema({
  date: {
    type: Date,
    required: true,
    default: Date.now
  },
  type: {
    type: String,
    required: true,
    enum: ['Achat', 'Vente', 'Frais', 'Autre']
  },
  amount: {
    type: Number,
    required: true
  },
  tvaAchat: {
    type: Number,
    default: 0
  },
  tvaVente: {
    type: Number,
    default: 0
  },
  tvaDeductible: {
    type: Number,
    default: 0
  },
  tvaCollectee: {
    type: Number,
    default: 0
  },
  tvaNet: {
    type: Number,
    default: 0
  },
  description: String,
  reference: String,
  category: {
    type: String,
    enum: [
      'Matériel',
      'Services',
      'Prestations',
      'Fournitures',
      'Taxes',
      'Salaires',
      'Loyer',
      'Autre'
    ],
    default: 'Autre'
  }
}, {
  timestamps: true
});

// Middleware pour calculer les valeurs TVA avant sauvegarde
FinanceRecordSchema.pre('save', function(next) {
  this.tvaDeductible = this.type === 'Achat' ? this.tvaAchat : 0;
  this.tvaCollectee = this.type === 'Vente' ? this.tvaVente : 0;
  this.tvaNet = this.tvaCollectee - this.tvaDeductible;
  next();
});

module.exports = mongoose.model('FinanceRecord', FinanceRecordSchema);
