const mongoose = require('mongoose');

const FicheBaieSchema = new mongoose.Schema({
  nom_baie: {
    type: String,
    required: true
  },
  emplacement: {
    type: String,
    default: null
  },
  capacite: {
    type: Number,
    default: null
  },
  type_baie: {
    type: String,
    enum: ['Rack', 'Etagère', 'Palettes', 'Autre'],
    default: 'Rack'
  },
  statut: {
    type: String,
    enum: ['Actif', 'Inactif'],
    default: 'Actif'
  },
  date_creation: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('FicheBaie', FicheBaieSchema);
