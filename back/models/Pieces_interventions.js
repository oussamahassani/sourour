const mongoose = require('mongoose');

// Schéma pour une pièce
const PieceSchema = new mongoose.Schema({
    // Identifiant unique de la pièce
    id_piece: { type: mongoose.Schema.Types.ObjectId, auto: true },

    // Référence de la pièce
    reference: { type: String, required: true },

    // Nom de la pièce
    nom: { type: String, required: true },

    // Description de la pièce
    description: { type: String },

    // Prix d'achat de la pièce
    prix_achat: { type: Number, required: true },

    // Prix de vente de la pièce
    prix_vente: { type: Number, required: true },

    // Quantité en stock de la pièce
    stock: { type: Number, required: true },

    // Seuil d'alerte pour la gestion du stock
    seuil_alerte: { type: Number, required: true },

    // Identifiant des pièces compatibles (peut être une liste d'ID de pièces compatibles)
    compatible_avec: { type: [mongoose.Schema.Types.ObjectId], ref: 'Piece' },

    // Identifiant du fournisseur de la pièce
    id_fournisseur: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'Fournisseur' },

    // Délai d'approvisionnement de la pièce en jours
    delai_approvisionnement: { type: Number, required: true }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.models.Piece || mongoose.model('Piece', PieceSchema);
