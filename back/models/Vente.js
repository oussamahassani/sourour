const mongoose = require('mongoose');

// Schéma pour une vente
const VenteSchema = new mongoose.Schema({
    // Identifiant unique de la vente
    idV: { type: mongoose.Schema.Types.ObjectId, auto: true },

    // Identifiant du client concerné par la vente
    idCL: { type: mongoose.Schema.Types.ObjectId, required: true },

    // Identifiant de l'utilisateur (vendeur) ayant réalisé la vente
    idU: { type: mongoose.Schema.Types.ObjectId, required: true },

    // Identifiant du produit ou service vendu
    idP: { type: mongoose.Schema.Types.ObjectId, required: true },

    // Identifiant de l'article spécifique (si applicable)
    id_article: { type: mongoose.Schema.Types.ObjectId },

    // Date de la vente
    date_vente: { type: Date, required: true },

    // Type de vente (par exemple : directe, en ligne, etc.)
    type_vente: { type: String, required: true },

    // Remise appliquée à la vente (en pourcentage)
    remise: { type: Number, default: 0 },

    // Validation par l'administrateur de la vente
    validation_admin: { type: Boolean, default: false },

    // Prix hors taxes de la vente
    prixHTV: { type: Number, required: true },

    // Taux de TVA applicable
    TVA: { type: Number, required: true },

    // Prix TTC (avec TVA)
    prixTTC: { type: Number, required: true },

    // Quantité de l'article vendu
    quantité: { type: Number, required: true },

    // Numéro de la vente
    numVENTE: { type: String, required: true },

    // Date de livraison prévue
    date_livraison: { type: Date, required: true },

    // Statut de la vente (par exemple : en attente, livrée, annulée, etc.)
    statut: { type: String, required: true },

    // Identifiant du document associé à la vente (facture, bon de commande, etc.)
    id_document: { type: mongoose.Schema.Types.ObjectId },

    // Garantie en mois associée au produit/service vendu
    garantie_mois: { type: Number, default: 0 }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Vente', VenteSchema);
