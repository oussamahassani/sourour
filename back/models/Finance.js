const mongoose = require('mongoose');

const FinanceSchema = new mongoose.Schema({
  id_bordereau: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bordereau',
    default: null
  },
  situation_comptes: {
    type: Number,
    required: true
  },
  mouvement_financier: {
    type: Number,
    required: true
  },
  date_mouvement: {
    type: Date,
    default: Date.now
  },
  description: {
    type: String,
    default: null
  },
  id_compte: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Compte',
    default: null
  },
  type_mouvement: {
    type: String,
    enum: ['Crédit', 'Débit', 'Transfert'],
    required: true
  }
});

module.exports = mongoose.model('Finance', FinanceSchema);
