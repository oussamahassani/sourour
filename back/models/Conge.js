const mongoose = require('mongoose');

const CongeSchema = new mongoose.Schema({
  id_employee: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Employee',
    required: true
  },
  date_debut: {
    type: Date,
    required: true
  },
  date_fin: {
    type: Date,
    required: true
  },
  type_conge: {
    type: String,
    enum: ['Payé', 'Sans solde', 'Maladie', 'Spécial'],
    required: true
  },
  status: {
    type: String,
    enum: ['Demandé', 'Approuvé', 'Refusé'],
    default: 'Demandé'
  },
  approuve_par: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Employee',
    default: null
  },
  date_demande: {
    type: Date,
    default: Date.now
  },
  motif: {
    type: String,
    default: null
  }
});

module.exports = mongoose.model('Conge', CongeSchema);
