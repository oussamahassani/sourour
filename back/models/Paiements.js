const mongoose = require('mongoose');

// Schéma pour un paiement
const PaiementSchema = new mongoose.Schema({
    // Identifiant unique du paiement
    idP: { type: mongoose.Schema.Types.ObjectId, auto: true },

    // Identifiant de l'acheteur
    idACH: { type: mongoose.Schema.Types.ObjectId, required: true },

    // Identifiant du vendeur
    idV: { type: mongoose.Schema.Types.ObjectId, required: true },

    // Méthode de paiement (carte bancaire, PayPal, etc.)
    methode_paiement: { type: String, required: true },

    // Numéro de transaction
    numero_transaction: { type: String, required: true },

    // Banque de traitement du paiement
    banque: { type: String, required: true },

    // Montant total du paiement
    montant: { type: Number, required: true },

    // Montant déjà payé
    montant_deja_paye: { type: Number, default: 0 },

    // Statut du paiement (en attente, effectué, échoué, etc.)
    statut_paiement: { type: String, required: true },

    // Date du paiement
    date_paiement: { type: Date, default: Date.now },

    // Validation de l'administrateur
    validation_admin: { type: Boolean, default: false },

    // Type de paiement (initial, acompte, solde, etc.)
    type: { type: String, required: true },

    // Reste à payer
    reste: { type: Number, required: true },

    // Date de la prochaine relance (si applicable)
    date_prochaine_relance: { type: Date },

    // Nombre de relances effectuées
    nombre_relances: { type: Number, default: 0 },

    // Identifiant du compte associé au paiement
    id_compte: { type: mongoose.Schema.Types.ObjectId, required: true }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Paiement', PaiementSchema);
