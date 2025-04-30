const mongoose = require('mongoose');

// Schéma pour un stock
const StockSchema = new mongoose.Schema({
    // Identifiant unique du stock
    id_stock: { type: mongoose.Schema.Types.ObjectId, auto: true },

    // Identifiant du produit lié au stock
    id_produit: { type: mongoose.Schema.Types.ObjectId, required: true },

    // Quantité disponible dans le stock
    quantite_disponible: { type: Number, required: true },

    // Seuil de réapprovisionnement (quantité à partir de laquelle il faut réapprovisionner le stock)
    seuil_reapprovisionnement: { type: Number, required: true },

    // Date de la dernière entrée de stock
    date_derniere_entree: { type: Date },

    // Date de la dernière sortie de stock
    date_derniere_sortie: { type: Date },

    // Statut du stock (actif, inactif, en rupture, etc.)
    statut_stock: { type: String, required: true },

    // Date du dernier inventaire réalisé
    date_dernier_inventaire: { type: Date }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Stock', StockSchema);
