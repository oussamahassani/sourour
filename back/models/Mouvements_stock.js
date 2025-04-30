const mongoose = require('mongoose');

// Schéma pour un mouvement d'article
const MouvementSchema = new mongoose.Schema({
    // Identifiant unique du mouvement
    id_mouvement: { type: mongoose.Schema.Types.ObjectId, auto: true },
    
    // Identifiant de l'article concerné
    id_article: { type: mongoose.Schema.Types.ObjectId, required: true },
    
    // Type de mouvement (entrée, sortie, ajustement, etc.)
    type_mouvement: { type: String, required: true },
    
    // Quantité affectée par le mouvement
    quantite: { type: Number, required: true },
    
    // Date du mouvement
    date_mouvement: { type: Date, default: Date.now },
    
    // Identifiant de l'utilisateur ayant effectué le mouvement
    id_utilisateur: { type: mongoose.Schema.Types.ObjectId, required: true },
    
    // Référence du document associé au mouvement
    reference_document: { type: String },
    
    // Type de document associé (facture, bon de livraison, etc.)
    type_document: { type: String },
    
    // Motif du mouvement
    motif: { type: String }
});

// Exporter le modèle pour utilisation dans d'autres fichiers
module.exports = mongoose.model('Mouvement', MouvementSchema);
