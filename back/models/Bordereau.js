// models/bordereau.js
const mongoose = require('mongoose');

const bordereauSchema = new mongoose.Schema({
  num_bordereau: {
    type: String,
    required: true
  },
  type_bordereau: {
    type: String,
    enum: ['Achat', 'Vente', 'Transfert'],
    default: null
  },
  date_bordereau: {
    type: Date,
    default: Date.now
  },
  montant: {
    type: Number,
    required: true
  },
  id_document: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Document',
    default: null
  }
});

module.exports = mongoose.model('Bordereau', bordereauSchema);
