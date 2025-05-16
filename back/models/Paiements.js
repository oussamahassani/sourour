const mongoose = require('mongoose');

const paiementSchema = new mongoose.Schema({
  reference: {
    type: String,
    required: true,
    unique: true
  },
  datePaiement: {
    type: Date,
    required: true,
    default: Date.now
  },
  responsable: {
    type: String,
    required: true
  },
  fournisseur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Fournisseur',
  
  },
  totalAPayer: {
    type: Number,
    required: true,
    min: 0
  },
  paiements: [{
    date: {
      type: Date,
      required: true
    },
    montantPaye: {
      type: Number,
      required: true,
      min: 0
    },
    modePaiement: {
      type: String,
  
    },
    statut: {
      type: String,
      enum: ['Payé', 'Partiellement payé', 'En attente'],
      default: 'Payé'
    }
  }],
  totalPaye: {
    type: Number,
    default: 0
  },
  resteAPayer: {
    type: Number,
    default: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Middleware pour calculer les totaux avant de sauvegarder
paiementSchema.pre('save', function(next) {
  this.totalPaye = this.paiements.reduce((sum, paiement) => sum + paiement.montantPaye, 0);
  this.resteAPayer = this.totalAPayer - this.totalPaye;
  this.updatedAt = Date.now();

  next();
});

// Méthode pour ajouter un paiement
paiementSchema.methods.ajouterPaiement = function(paiementData) {
  this.paiements.push(paiementData);
  this.totalPaye += paiementData.montantPaye;
  this.resteAPayer = this.totalAPayer - this.totalPaye;
  return this.save();
};

// Méthode pour supprimer un paiement
paiementSchema.methods.supprimerPaiement = function(paiementId) {
  const paiement = this.paiements.id(paiementId);
  if (!paiement) throw new Error('Paiement non trouvé');
  
  this.totalPaye -= paiement.montantPaye;
  this.resteAPayer = this.totalAPayer - this.totalPaye;
  paiement.remove();
  return this.save();
};

module.exports = mongoose.model('Paiement', paiementSchema);