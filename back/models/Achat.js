const mongoose = require('mongoose');


const AchatSchema = new mongoose.Schema({
  id_article: { type: mongoose.Schema.Types.ObjectId, ref: 'Article', required: false },
  id_fournisseur: { type: mongoose.Schema.Types.ObjectId, ref: 'fournisseur', required: false },
  id_utilisateur: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false },
  prix_achatHT: { type: Number, required: false },
  date_achat: { type: Date, required: false },
  type_achat: { type: String, enum: ['Direct', 'Commandé'], required: false },
  validation_admin: { type: Boolean, required: false },
  TVA: { type: Number, required: false },
  prix_achatTTC: { type: Number, required: false },
  id_paiement: { type: mongoose.Schema.Types.ObjectId, ref: 'Paiement', required: false },
  quantité: { type: Number, required: false },
  numACHAT: { type: String, required: false },
  delai_livraison: { type: Number, required: false },
  id_document: { type: mongoose.Schema.Types.ObjectId, ref: 'Document', required: false },
}, { timestamps: true });

// Création du modèle
module.exports = mongoose.model('Achat', AchatSchema);
